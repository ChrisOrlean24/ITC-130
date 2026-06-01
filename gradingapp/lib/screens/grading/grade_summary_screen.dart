import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../providers/grade_summary_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/grading/grade_badge.dart';
import '../../widgets/common/loading_indicator.dart';

class GradeSummaryScreen extends ConsumerWidget {
  final String studentId;
  const GradeSummaryScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentProvider(studentId));
    final summary = ref.watch(gradeSummaryProvider(studentId));
    final breakdown = ref.watch(gradeBreakdownProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: studentAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (student) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Final grade card ───────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.gradeColor(summary.finalGrade)
                            .withOpacity(0.15),
                        AppTheme.surface,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.gradeColor(summary.finalGrade)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student?.name ?? '',
                              style: AppTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Final Grade',
                              style: AppTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              summary.remarks,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gradeColor(
                                    summary.finalGrade),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              summary.isPassing
                                  ? '✓ Passing'
                                  : '✗ Failing',
                              style: TextStyle(
                                fontSize: 12,
                                color: summary.isPassing
                                    ? AppTheme.success
                                    : AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GradeBadge(
                        grade: summary.finalGrade,
                        size: GradeBadgeSize.large,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Breakdown ──────────────────────────────────────────
                Text(
                  'GRADE BREAKDOWN',
                  style: AppTheme.labelSmall
                      .copyWith(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),

                ...breakdown.map((entry) => _BreakdownRow(entry: entry)),

                const SizedBox(height: 24),

                // ── Total row ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.gradeColor(summary.finalGrade)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.gradeColor(summary.finalGrade)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Final Grade',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${summary.finalGrade.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color:
                              AppTheme.gradeColor(summary.finalGrade),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final GradeBreakdownEntry entry;
  const _BreakdownRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.gradeColor(entry.rawScore);
    final barWidth = entry.rawScore / 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    '${entry.rawScore.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 13,
                      color: entry.rawScore > 0 ? color : AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '× ${entry.weightLabel}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '= ${entry.weightedScore.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: entry.rawScore > 0
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barWidth.clamp(0.0, 1.0),
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation<Color>(
                  entry.rawScore > 0 ? color : AppTheme.textMuted),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
