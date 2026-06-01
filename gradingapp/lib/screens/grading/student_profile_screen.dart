import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../models/student.dart';
import '../../providers/student_provider.dart';
import '../../providers/grade_summary_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/grading/grade_badge.dart';

class StudentProfileScreen extends ConsumerWidget {
  final String studentId;
  const StudentProfileScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentProvider(studentId));
    final summary = ref.watch(gradeSummaryProvider(studentId));

    return Scaffold(
      body: studentAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (student) {
          if (student == null) {
            return const Center(child: Text('Student not found.'));
          }
          final sectionColor = student.section == StudentSection.sectionA
              ? AppTheme.sectionA
              : AppTheme.sectionB;

          return CustomScrollView(
            slivers: [
              // ── App bar ────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () =>
                        context.push('/grading/student/$studentId/edit'),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          sectionColor.withOpacity(0.15),
                          AppTheme.background,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Avatar
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: sectionColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: sectionColor, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  student.name.isNotEmpty
                                      ? student.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: sectionColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(student.name,
                                      style: AppTheme.headlineMedium),
                                  const SizedBox(height: 2),
                                  Text(student.email,
                                      style: AppTheme.bodyMedium),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                          sectionColor.withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                      border: Border.all(
                                          color: sectionColor
                                              .withOpacity(0.4)),
                                    ),
                                    child: Text(
                                      'Section ${student.section.label}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: sectionColor,
                                      ),
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
                    ),
                  ),
                ),
              ),

              // ── Grade categories grid ──────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate([
                    _CategoryTile(
                      icon: Icons.calendar_today_outlined,
                      label: 'Attendance',
                      score: summary.attendanceScore,
                      onTap: () => context.push(
                          '/grading/student/$studentId/attendance'),
                    ),
                    _CategoryTile(
                      icon: Icons.quiz_outlined,
                      label: 'Quizzes',
                      score: summary.quizScore,
                      onTap: () => context
                          .push('/grading/student/$studentId/quizzes'),
                    ),
                    _CategoryTile(
                      icon: Icons.assignment_outlined,
                      label: 'Exams',
                      score: summary.prelimScore
                          .clamp(0, 100)
                          .toDouble(), // shows prelim as preview
                      onTap: () => context
                          .push('/grading/student/$studentId/exams'),
                    ),
                    _CategoryTile(
                      icon: Icons.task_outlined,
                      label: 'Activities',
                      score: summary.activityScore,
                      onTap: () => context.push(
                          '/grading/student/$studentId/activities'),
                    ),
                    _CategoryTile(
                      icon: Icons.record_voice_over_outlined,
                      label: 'Oral Recitation',
                      score: summary.oralRecitationScore,
                      onTap: () => context.push(
                          '/grading/student/$studentId/oral-recitations'),
                    ),
                    _CategoryTile(
                      icon: Icons.folder_outlined,
                      label: 'Projects',
                      score: summary.projectScore,
                      onTap: () => context.push(
                          '/grading/student/$studentId/projects'),
                    ),
                  ]),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                ),
              ),

              // ── View full summary button ────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                sliver: SliverToBoxAdapter(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                        '/grading/student/$studentId/grade-summary'),
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: const Text('View Full Grade Summary'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side:
                          const BorderSide(color: AppTheme.accent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double score;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.gradeColor(score);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 2),
                Text(
                  score > 0
                      ? '${score.toStringAsFixed(1)}%'
                      : '—',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: score > 0 ? color : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
