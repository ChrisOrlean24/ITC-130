import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../providers/project_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/grading/grade_entry_tile.dart';
import '../../widgets/common/form_helpers.dart';

class ProjectScreen extends ConsumerWidget {
  final String studentId;
  const ProjectScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectStreamProvider(studentId));
    final average = ref.watch(projectAverageScoreProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
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
      body: projectsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (projects) {
          if (projects.isEmpty) {
            return const EmptyState(
              icon: Icons.folder_outlined,
              title: 'No projects yet',
              subtitle: 'Tap + to add a project score.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final p = projects[i];
              return GradeEntryTile(
                date: p.date,
                label: 'Project',
                score: p.score,
                total: p.totalPoints,
                percentage: p.percentage,
                onDelete: () => ref
                    .read(projectNotifierProvider(studentId).notifier)
                    .deleteProject(p.projectId),
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
      builder: (_) => _ProjectSheet(studentId: studentId),
    );
  }
}

class _ProjectSheet extends ConsumerStatefulWidget {
  final String studentId;
  const _ProjectSheet({required this.studentId});

  @override
  ConsumerState<_ProjectSheet> createState() => _ProjectSheetState();
}

class _ProjectSheetState extends ConsumerState<_ProjectSheet> {
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
          Text('Add Project', style: AppTheme.headlineMedium),
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
                  hint: '100',
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
        .read(projectNotifierProvider(widget.studentId).notifier)
        .addProject(date: _date, totalPoints: total, score: score);
    if (mounted) Navigator.pop(context);
  }
}
