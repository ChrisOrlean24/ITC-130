import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../models/todo.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class TodoFormScreen extends ConsumerStatefulWidget {
  /// If null, we are creating. If set, we are editing.
  final String? todoId;
  const TodoFormScreen({super.key, this.todoId});

  @override
  ConsumerState<TodoFormScreen> createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends ConsumerState<TodoFormScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();

  TodoPriority _priority = TodoPriority.medium;
  DateTime? _dueDate;
  bool _isLoading = false;
  Todo? _existing;

  bool get _isEditing => widget.todoId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  void _loadExisting() {
    final todos = ref.read(todoProvider).valueOrNull ?? [];
    final todo = todos.where((t) => t.id == widget.todoId).firstOrNull;
    if (todo != null) {
      setState(() {
        _existing = todo;
        _titleController.text = todo.title;
        _descController.text = todo.description ?? '';
        _categoryController.text = todo.category ?? '';
        _priority = todo.priority;
        _dueDate = todo.dueDate;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      if (_isEditing && _existing != null) {
        await ref.read(todoProvider.notifier).updateTodo(
              _existing!.copyWith(
                title: _titleController.text.trim(),
                description: _descController.text.trim().isEmpty
                    ? null
                    : _descController.text.trim(),
                priority: _priority,
                dueDate: _dueDate,
                category: _categoryController.text.trim().isEmpty
                    ? null
                    : _categoryController.text.trim(),
              ),
            );
      } else {
        await ref.read(todoProvider.notifier).addTodo(
              title: _titleController.text.trim(),
              description: _descController.text.trim().isEmpty
                  ? null
                  : _descController.text.trim(),
              priority: _priority,
              dueDate: _dueDate,
              category: _categoryController.text.trim().isEmpty
                  ? null
                  : _categoryController.text.trim(),
            );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
              primary: AppTheme.accent,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            AppTextField(
              controller: _titleController,
              label: 'Task title',
              hint: 'What needs to be done?',
              autofocus: !_isEditing,
            ),
            const SizedBox(height: 16),

            // Description
            AppTextField(
              controller: _descController,
              label: 'Description (optional)',
              hint: 'Add more details...',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Category
            AppTextField(
              controller: _categoryController,
              label: 'Category (optional)',
              hint: 'e.g. grading, personal',
            ),
            const SizedBox(height: 24),

            // Priority
            _SectionLabel('Priority'),
            const SizedBox(height: 10),
            Row(
              children: TodoPriority.values.map((p) {
                final isSelected = _priority == p;
                final color = _priorityColor(p);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.15)
                              : AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : AppTheme.divider,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _priorityIcon(p),
                              color: isSelected ? color : AppTheme.textMuted,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.name[0].toUpperCase() + p.name.substring(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? color : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Due date
            _SectionLabel('Due Date'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: _dueDate != null
                          ? AppTheme.accent
                          : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _dueDate != null
                            ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                            : 'No due date',
                        style: TextStyle(
                          color: _dueDate != null
                              ? AppTheme.textPrimary
                              : AppTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: const Icon(Icons.close,
                            size: 16, color: AppTheme.textMuted),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),

            AppButton(
              label: _isEditing ? 'Save Changes' : 'Add Task',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
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

  IconData _priorityIcon(TodoPriority p) {
    switch (p) {
      case TodoPriority.low:
        return Icons.arrow_downward;
      case TodoPriority.medium:
        return Icons.remove;
      case TodoPriority.high:
        return Icons.arrow_upward;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTheme.labelSmall.copyWith(color: AppTheme.textSecondary),
    );
  }
}
