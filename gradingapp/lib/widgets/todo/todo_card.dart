import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = todo.status == TodoStatus.completed;
    final priorityColor = _priorityColor(todo.priority);

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline,
            color: AppTheme.error, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onEdit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.surface.withOpacity(0.5)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? AppTheme.divider
                  : priorityColor.withOpacity(0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? priorityColor
                            : Colors.transparent,
                        border: Border.all(
                          color: isCompleted
                              ? priorityColor
                              : AppTheme.textMuted,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check,
                              size: 13, color: Colors.white)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isCompleted
                            ? AppTheme.textMuted
                            : AppTheme.textPrimary,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppTheme.textMuted,
                      ),
                    ),
                    if (todo.description != null &&
                        todo.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        todo.description!,
                        style: AppTheme.bodyMedium.copyWith(
                          fontSize: 13,
                          color: isCompleted
                              ? AppTheme.textMuted
                              : AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _MetaChip(
                          label: todo.priority.name,
                          color: priorityColor,
                        ),
                        if (todo.category != null) ...[
                          const SizedBox(width: 6),
                          _MetaChip(
                            label: todo.category!,
                            color: AppTheme.textMuted,
                          ),
                        ],
                        const Spacer(),
                        if (todo.dueDate != null)
                          _DueDateBadge(dueDate: todo.dueDate!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(TodoPriority p) {
    switch (p) {
      case TodoPriority.low:
        return AppTheme.priorityLow;
      case TodoPriority.medium:
        return AppTheme.priorityMedium;
      case TodoPriority.high:
        return AppTheme.priorityHigh;
    }
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MetaChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  const _DueDateBadge({required this.dueDate});

  @override
  Widget build(BuildContext context) {
    final isOverdue = dueDate.isBefore(DateTime.now());
    final color = isOverdue ? AppTheme.error : AppTheme.textMuted;

    return Row(
      children: [
        Icon(Icons.schedule, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          '${dueDate.day}/${dueDate.month}',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
