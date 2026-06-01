import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../models/student.dart';
import '../../providers/student_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/grading/student_card.dart';

class StudentListScreen extends ConsumerWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredStudentsProvider);
    final sectionFilter = ref.watch(sectionFilterProvider);
    final searchQuery = ref.watch(studentSearchQueryProvider);

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
                      Text('Students', style: AppTheme.displayLarge),
                      const SizedBox(height: 4),
                      filteredAsync.when(
                        data: (list) => Text(
                          '${list.length} student${list.length == 1 ? '' : 's'}',
                          style: AppTheme.bodyMedium
                              .copyWith(color: AppTheme.accent),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Class overview button
                      IconButton(
                        onPressed: () => context.push('/grading/overview'),
                        icon: const Icon(Icons.bar_chart_outlined),
                        color: AppTheme.textSecondary,
                        tooltip: 'Class overview',
                      ),
                      // Add student button
                      IconButton(
                        onPressed: () =>
                            context.push('/grading/new-student'),
                        icon: const Icon(Icons.person_add_outlined),
                        color: AppTheme.accent,
                        tooltip: 'Add student',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Search ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                onChanged: (v) => ref
                    .read(studentSearchQueryProvider.notifier)
                    .state = v,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search students...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppTheme.textMuted, size: 20),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              color: AppTheme.textMuted, size: 18),
                          onPressed: () => ref
                              .read(studentSearchQueryProvider.notifier)
                              .state = '',
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Section filter chips ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _SectionChip(
                    label: 'All',
                    isSelected: sectionFilter == null,
                    color: AppTheme.accent,
                    onTap: () => ref
                        .read(sectionFilterProvider.notifier)
                        .state = null,
                  ),
                  const SizedBox(width: 8),
                  _SectionChip(
                    label: '3A',
                    isSelected: sectionFilter == StudentSection.sectionA,
                    color: AppTheme.sectionA,
                    onTap: () => ref
                        .read(sectionFilterProvider.notifier)
                        .state = StudentSection.sectionA,
                  ),
                  const SizedBox(width: 8),
                  _SectionChip(
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

            const SizedBox(height: 8),

            // ── Student list ──────────────────────────────────────────────
            Expanded(
              child: filteredAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: AppTheme.bodyMedium
                          .copyWith(color: AppTheme.error)),
                ),
                data: (students) {
                  if (students.isEmpty) {
                    return EmptyState(
                      icon: Icons.people_outline,
                      title: searchQuery.isNotEmpty
                          ? 'No results'
                          : 'No students yet',
                      subtitle: searchQuery.isNotEmpty
                          ? 'Try a different search term.'
                          : 'Tap the + icon to add your first student.',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return StudentCard(
                        student: student,
                        onTap: () => context
                            .push('/grading/student/${student.studentId}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _SectionChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppTheme.surfaceElevated,
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
