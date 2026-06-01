import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';

class TodoFilterBar extends ConsumerWidget {
  const TodoFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(todoStatusFilterProvider);
    final priorityFilter = ref.watch(todoPriorityFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Status filters
          _FilterChip(
            label: 'All',
            isSelected:
                statusFilter == null && priorityFilter == null,
            onTap: () {
              ref.read(todoStatusFilterProvider.notifier).state = null;
              ref.read(todoPriorityFilterProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pending',
            isSelected: statusFilter == TodoStatus.pending,
            color: AppTheme.accent,
            onTap: () {
              ref.read(todoStatusFilterProvider.notifier).state =
                  TodoStatus.pending;
              ref.read(todoPriorityFilterProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Done',
            isSelected: statusFilter == TodoStatus.completed,
            color: AppTheme.success,
            onTap: () {
              ref.read(todoStatusFilterProvider.notifier).state =
                  TodoStatus.completed;
              ref.read(todoPriorityFilterProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),

          // Divider
          Container(
            width: 1,
            height: 20,
            color: AppTheme.divider,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const SizedBox(width: 4),

          // Priority filters
          _FilterChip(
            label: '↑ High',
            isSelected: priorityFilter == TodoPriority.high,
            color: AppTheme.priorityHigh,
            onTap: () {
              ref.read(todoPriorityFilterProvider.notifier).state =
                  TodoPriority.high;
              ref.read(todoStatusFilterProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '— Med',
            isSelected: priorityFilter == TodoPriority.medium,
            color: AppTheme.priorityMedium,
            onTap: () {
              ref.read(todoPriorityFilterProvider.notifier).state =
                  TodoPriority.medium;
              ref.read(todoStatusFilterProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '↓ Low',
            isSelected: priorityFilter == TodoPriority.low,
            color: AppTheme.priorityLow,
            onTap: () {
              ref.read(todoPriorityFilterProvider.notifier).state =
                  TodoPriority.low;
              ref.read(todoStatusFilterProvider.notifier).state = null;
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color = AppTheme.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppTheme.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
