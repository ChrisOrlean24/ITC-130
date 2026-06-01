import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/todo/todo_card.dart';
import '../../widgets/todo/todo_filter_bar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredTodosProvider);
    final pendingCount = ref.watch(pendingTodoCountProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Tasks', style: AppTheme.displayLarge),
                      const SizedBox(height: 4),
                      Text(
                        '$pendingCount pending',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                  _HeaderActions(
                    onClearCompleted: () =>
                        ref.read(todoProvider.notifier).deleteCompleted(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Filter bar ────────────────────────────────────────────────
            const TodoFilterBar(),

            const SizedBox(height: 8),

            // ── Todo list ─────────────────────────────────────────────────
            Expanded(
              child: filteredAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) => _ErrorState(message: e.toString()),
                data: (todos) {
                  if (todos.isEmpty) {
                    return const EmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'All clear!',
                      subtitle: 'Tap + to add your first task.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    itemCount: todos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return TodoCard(
                        todo: todo,
                        onToggle: () => ref
                            .read(todoProvider.notifier)
                            .toggleStatus(todo),
                        onEdit: () =>
                            context.push('/todos/edit/${todo.id}'),
                        onDelete: () => ref
                            .read(todoProvider.notifier)
                            .deleteTodo(todo.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/todos/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  final VoidCallback onClearCompleted;
  const _HeaderActions({required this.onClearCompleted});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
      color: AppTheme.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'clear') onClearCompleted();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'clear',
          child: Row(
            children: [
              Icon(Icons.delete_sweep_outlined,
                  color: AppTheme.error, size: 18),
              SizedBox(width: 10),
              Text('Clear completed',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Error: $message',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
