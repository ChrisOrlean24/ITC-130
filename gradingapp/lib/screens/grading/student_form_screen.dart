import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../models/student.dart';
import '../../providers/student_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final String? studentId;
  const StudentFormScreen({super.key, this.studentId});

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  StudentSection _section = StudentSection.sectionA;
  bool _isLoading = false;
  Student? _existing;

  bool get _isEditing => widget.studentId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  Future<void> _loadExisting() async {
    final student =
        await ref.read(studentServiceProvider).getStudent(widget.studentId!);
    if (student != null && mounted) {
      setState(() {
        _existing = student;
        _nameController.text = student.name;
        _emailController.text = student.email;
        _section = student.section;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      if (_isEditing && _existing != null) {
        await ref.read(studentNotifierProvider.notifier).updateStudent(
              _existing!.copyWith(
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                section: _section,
              ),
            );
      } else {
        await ref.read(studentNotifierProvider.notifier).addStudent(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              section: _section,
            );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Student' : 'New Student'),
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
            AppTextField(
              controller: _nameController,
              label: 'Full name',
              hint: 'e.g. Juan dela Cruz',
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              label: 'Email address',
              hint: 'student@school.edu',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            // Section picker
            Text(
              'SECTION',
              style: AppTheme.labelSmall
                  .copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 10),
            Row(
              children: StudentSection.values.map((s) {
                final isSelected = _section == s;
                final color = s == StudentSection.sectionA
                    ? AppTheme.sectionA
                    : AppTheme.sectionB;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _section = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.15)
                              : AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? color : AppTheme.divider,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            s.label,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? color
                                  : AppTheme.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            AppButton(
              label: _isEditing ? 'Save Changes' : 'Add Student',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
