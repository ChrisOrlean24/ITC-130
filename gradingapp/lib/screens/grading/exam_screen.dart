import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../models/exam.dart';
import '../../providers/exam_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/grading/grade_entry_tile.dart';
import '../../widgets/common/form_helpers.dart';

class ExamScreen extends ConsumerWidget {
  final String studentId;
  const ExamScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examStreamProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: examsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (exams) {
          if (exams.isEmpty) {
            return const EmptyState(
              icon: Icons.assignment_outlined,
              title: 'No exams yet',
              subtitle: 'Tap + to add an exam score.',
            );
          }

          // Group by type
          final grouped = <ExamType, List<Exam>>{};
          for (final e in exams) {
            grouped.putIfAbsent(e.type, () => []).add(e);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            children: ExamType.values.map((type) {
              final typeExams = grouped[type] ?? [];
              if (typeExams.isEmpty) return const SizedBox.shrink();

              final typeLabel =
                  type.label[0].toUpperCase() + type.label.substring(1);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Text(
                      typeLabel,
                      style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.textSecondary),
                    ),
                  ),
                  ...typeExams.map((exam) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GradeEntryTile(
                          date: exam.date,
                          label: '$typeLabel Exam',
                          score: exam.score,
                          total: exam.totalItems,
                          percentage: exam.percentage,
                          onDelete: () => ref
                              .read(examNotifierProvider(studentId)
                                  .notifier)
                              .deleteExam(exam.examId),
                        ),
                      )),
                ],
              );
            }).toList(),
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
      builder: (_) => _ExamSheet(studentId: studentId),
    );
  }
}

class _ExamSheet extends ConsumerStatefulWidget {
  final String studentId;
  const _ExamSheet({required this.studentId});

  @override
  ConsumerState<_ExamSheet> createState() => _ExamSheetState();
}

class _ExamSheetState extends ConsumerState<_ExamSheet> {
  final _scoreController = TextEditingController();
  final _totalController = TextEditingController();
  DateTime _date = DateTime.now();
  ExamType _type = ExamType.prelim;
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
          Text('Add Exam', style: AppTheme.headlineMedium),
          const SizedBox(height: 20),
          DateRow(
              date: _date, onChanged: (d) => setState(() => _date = d)),
          const SizedBox(height: 16),
          TypeToggle<ExamType>(
            values: ExamType.values,
            selected: _type,
            labelOf: (t) =>
                t.label[0].toUpperCase() + t.label.substring(1),
            onChanged: (t) => setState(() => _type = t),
          ),
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
                  label: 'Total Items',
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
    await ref.read(examNotifierProvider(widget.studentId).notifier).addExam(
          date: _date,
          type: _type,
          totalItems: total,
          score: score,
        );
    if (mounted) Navigator.pop(context);
  }
}
