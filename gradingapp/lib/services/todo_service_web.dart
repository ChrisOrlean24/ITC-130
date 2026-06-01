import 'dart:convert';
import 'dart:html' as html;

import '../models/todo.dart';

class TodoService {
  static const _storageKey = 'todos';

  Future<void> _saveTodos(List<Todo> todos) async {
    final jsonString = jsonEncode(todos.map((todo) => todo.toMap()).toList());
    html.window.localStorage[_storageKey] = jsonString;
  }

  Future<List<Todo>> _loadTodos() async {
    final raw = html.window.localStorage[_storageKey];
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(Todo.fromMap)
        .toList();
  }

  Future<void> addTodo(Todo todo) async {
    final todos = await _loadTodos();
    todos.insert(0, todo);
    await _saveTodos(todos);
  }

  Future<List<Todo>> getAllTodos() async {
    final todos = await _loadTodos();
    todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return todos;
  }

  Future<List<Todo>> getTodosByStatus(TodoStatus status) async {
    final todos = await _loadTodos();
    return todos.where((todo) => todo.status == status).toList();
  }

  Future<List<Todo>> getTodosByPriority(TodoPriority priority) async {
    final todos = await _loadTodos();
    return todos.where((todo) => todo.priority == priority).toList();
  }

  Future<void> updateTodo(Todo todo) async {
    final todos = await _loadTodos();
    final index = todos.indexWhere((item) => item.id == todo.id);
    if (index != -1) {
      todos[index] = todo;
      await _saveTodos(todos);
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    final updated = todo.copyWith(
      status: todo.status == TodoStatus.pending
          ? TodoStatus.completed
          : TodoStatus.pending,
    );
    await updateTodo(updated);
  }

  Future<void> deleteTodo(String id) async {
    final todos = await _loadTodos();
    todos.removeWhere((todo) => todo.id == id);
    await _saveTodos(todos);
  }

  Future<void> deleteCompleted() async {
    final todos = await _loadTodos();
    todos.removeWhere((todo) => todo.status == TodoStatus.completed);
    await _saveTodos(todos);
  }
}
