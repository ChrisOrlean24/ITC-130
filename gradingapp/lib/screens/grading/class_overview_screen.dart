import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../models/student.dart';
import '../../providers/student_provider.dart';
import '../../providers/grade_summary_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/grading/grade_badge.dart';

class ClassOverviewScreen extends ConsumerWidget {
  const ClassOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsStreamProvider);
    final sectionFilter = ref.watch(sectionFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Overview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // ── Section filter ─────────────────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                _OverviewChip(
                  label: 'All',
                  isSelected: sectionFilter == null,
                  onTap: () => ref
                      .read(sectionFilterProvider.notifier)
                      .state = null,
                ),
                const SizedBox(width: 8),
                _OverviewChip(
                  label: '3A',
                  isSelected: sectionFilter == StudentSection.sectionA,
                  color: AppTheme.sectionA,
                  onTap: () => ref
                      .read(sectionFilterProvider.notifier)
                      .state = StudentSection.sectionA,
                ),
                const SizedBox(width: 8),
                _OverviewChip(
                  label: '3B',
                  isSelected: sectionFilter == StudentSection.sectionB,
                  color: AppTheme.sectionB,
                  onTap: () => ref
                      .read(sectionFilterProvider.notifier)
                      .state = StudentSection.sectionB,
                ),
              ],
            ),
          ),

          // ── Table header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Student',
                      style: AppTheme.labelSmall
                          .copyWith(color: AppTheme.textSecondary)),
                ),
                Expanded(
                  child: Text('Sec',
                      style: AppTheme.labelSmall
                          .copyWith(color: AppTheme.textSecondary),
                      textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('Grade',
                      style: AppTheme.labelSmall
                          .copyWith(color: AppTheme.textSecondary),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // ── Student rows ───────────────────────────────────────────────
          Expanded(
            child: studentsAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (students) {
                if (students.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No students',
                    subtitle: 'Add students to see their grades here.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 40),
                  itemCount: students.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 24),
                  itemBuilder: (context, i) {
                    final student = students[i];
                    return _StudentRow(student: student);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends ConsumerWidget {
  final Student student;
  const _StudentRow({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary =
        ref.watch(gradeSummaryProvider(student.studentId));
    final sectionColor = student.section == StudentSection.sectionA
        ? AppTheme.sectionA
        : AppTheme.sectionB;

    return InkWell(
      onTap: () => context
          .push('/grading/student/${student.studentId}/grade-summary'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            // Avatar + name
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: sectionColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        student.name.isNotEmpty
                            ? student.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: sectionColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Section
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sectionColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    student.section.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: sectionColor,
                    ),
                  ),
                ),
              ),
            ),
            // Grade badge
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: GradeBadge(
                  grade: summary.finalGrade,
                  size: GradeBadgeSize.small,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _OverviewChip({
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? color : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
