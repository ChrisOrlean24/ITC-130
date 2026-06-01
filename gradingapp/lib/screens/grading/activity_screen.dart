import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/grading/grade_entry_tile.dart';
import '../../widgets/common/form_helpers.dart';

class ActivityScreen extends ConsumerWidget {
  final String studentId;
  const ActivityScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activityStreamProvider(studentId));
    final average = ref.watch(activityAverageScoreProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (average > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'Avg: ${average.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: AppTheme.gradeColor(average),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: activitiesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (activities) {
          if (activities.isEmpty) {
            return const EmptyState(
              icon: Icons.task_outlined,
              title: 'No activities yet',
              subtitle: 'Tap + to add an activity score.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            itemCount: activities.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final a = activities[i];
              return GradeEntryTile(
                date: a.date,
                label: 'Activity',
                score: a.score,
                total: a.totalPoints,
                percentage: a.percentage,
                onDelete: () => ref
                    .read(activityNotifierProvider(studentId).notifier)
                    .deleteActivity(a.activityId),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ActivitySheet(studentId: studentId),
    );
  }
}

class _ActivitySheet extends ConsumerStatefulWidget {
  final String studentId;
  const _ActivitySheet({required this.studentId});

  @override
  ConsumerState<_ActivitySheet> createState() => _ActivitySheetState();
}

class _ActivitySheetState extends ConsumerState<_ActivitySheet> {
  final _scoreController = TextEditingController();
  final _totalController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _scoreController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Activity', style: AppTheme.headlineMedium),
          const SizedBox(height: 20),
          DateRow(
              date: _date, onChanged: (d) => setState(() => _date = d)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _scoreController,
                  label: 'Score',
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  controller: _totalController,
                  label: 'Total Points',
                  hint: '50',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final score = int.tryParse(_scoreController.text);
    final total = int.tryParse(_totalController.text);
    if (score == null || total == null || total == 0) return;

    setState(() => _loading = true);
    await ref
        .read(activityNotifierProvider(widget.studentId).notifier)
        .addActivity(date: _date, totalPoints: total, score: score);
    if (mounted) Navigator.pop(context);
  }
}
