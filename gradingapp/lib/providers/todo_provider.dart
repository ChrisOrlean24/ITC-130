import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';

// ── Service provider ─────────────────────────────────────────────────────────

final todoServiceProvider = Provider<TodoService>((ref) => TodoService());

// ── Filter state providers ────────────────────────────────────────────────────

final todoStatusFilterProvider = StateProvider<TodoStatus?>((ref) => null);
final todoPriorityFilterProvider = StateProvider<TodoPriority?>((ref) => null);

// ── Main notifier ─────────────────────────────────────────────────────────────

class TodoNotifier extends AsyncNotifier<List<Todo>> {
  TodoService get _service => ref.read(todoServiceProvider);

  @override
  Future<List<Todo>> build() async {
    return _service.getAllTodos();
  }

  Future<void> addTodo({
    required String title,
    String? description,
    TodoPriority priority = TodoPriority.medium,
    DateTime? dueDate,
    String? category,
  }) async {
    final todo = Todo(
      id: const Uuid().v4(),
      title: title,
      description: description,
      priority: priority,
      status: TodoStatus.pending,
      dueDate: dueDate,
      category: category,
      createdAt: DateTime.now(),
    );
    await _service.addTodo(todo);
    ref.invalidateSelf();
  }

  Future<void> updateTodo(Todo todo) async {
    await _service.updateTodo(todo);
    ref.invalidateSelf();
  }

  Future<void> toggleStatus(Todo todo) async {
    await _service.toggleTodoStatus(todo);
    ref.invalidateSelf();
  }

  Future<void> deleteTodo(String id) async {
    await _service.deleteTodo(id);
    ref.invalidateSelf();
  }

  Future<void> deleteCompleted() async {
    await _service.deleteCompleted();
    ref.invalidateSelf();
  }
}

final todoProvider =
    AsyncNotifierProvider<TodoNotifier, List<Todo>>(TodoNotifier.new);

// ── Derived / filtered providers ──────────────────────────────────────────────

/// Filtered todo list based on active status + priority filters
final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todos = ref.watch(todoProvider);
  final statusFilter = ref.watch(todoStatusFilterProvider);
  final priorityFilter = ref.watch(todoPriorityFilterProvider);

  return todos.whenData((list) {
    var filtered = list;
    if (statusFilter != null) {
      filtered = filtered.where((t) => t.status == statusFilter).toList();
    }
    if (priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == priorityFilter).toList();
    }
    return filtered;
  });
});

/// Count of pending todos (used for badges)
final pendingTodoCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoProvider).valueOrNull ?? [];
  return todos.where((t) => t.status == TodoStatus.pending).length;
});
