import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../models/student.dart';
import '../../providers/grade_summary_provider.dart';
import 'grade_badge.dart';

class StudentCard extends ConsumerWidget {
  final Student student;
  final VoidCallback onTap;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary =
        ref.watch(gradeSummaryProvider(student.studentId));
    final sectionColor = student.section == StudentSection.sectionA
        ? AppTheme.sectionA
        : AppTheme.sectionB;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: sectionColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border:
                    Border.all(color: sectionColor.withOpacity(0.4)),
              ),
              child: Center(
                child: Text(
                  student.name.isNotEmpty
                      ? student.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: sectionColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: AppTheme.titleMedium.copyWith(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    student.email,
                    style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: sectionColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Section ${student.section.label}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sectionColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Grade badge
            GradeBadge(
              grade: summary.finalGrade,
              size: GradeBadgeSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
