import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../models/quiz.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/form_helpers.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/grading/grade_entry_tile.dart';

class QuizScreen extends ConsumerWidget {
  final String studentId;
  const QuizScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(quizStreamProvider(studentId));
    final average = ref.watch(quizAverageScoreProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
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
      body: quizzesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (quizzes) {
          if (quizzes.isEmpty) {
            return const EmptyState(
              icon: Icons.quiz_outlined,
              title: 'No quizzes yet',
              subtitle: 'Tap + to add a quiz score.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            itemCount: quizzes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final q = quizzes[i];
              return GradeEntryTile(
                date: q.date,
                label: '${q.type.label[0].toUpperCase()}${q.type.label.substring(1)} Quiz',
                score: q.score,
                total: q.totalItems,
                percentage: q.percentage,
                onDelete: () => ref
                    .read(quizNotifierProvider(studentId).notifier)
                    .deleteQuiz(q.quizId),
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
      builder: (_) => _QuizSheet(studentId: studentId),
    );
  }
}

class _QuizSheet extends ConsumerStatefulWidget {
  final String studentId;
  const _QuizSheet({required this.studentId});

  @override
  ConsumerState<_QuizSheet> createState() => _QuizSheetState();
}

class _QuizSheetState extends ConsumerState<_QuizSheet> {
  final _scoreController = TextEditingController();
  final _totalController = TextEditingController();
  DateTime _date = DateTime.now();
  QuizType _type = QuizType.short;
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
          Text('Add Quiz', style: AppTheme.headlineMedium),
          const SizedBox(height: 20),
          // Date
          DateRow(date: _date, onChanged: (d) => setState(() => _date = d)),
          const SizedBox(height: 16),
          TypeToggle<QuizType>(
            values: QuizType.values,
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
                  hint: '20',
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
    await ref.read(quizNotifierProvider(widget.studentId).notifier).addQuiz(
          date: _date,
          type: _type,
          totalItems: total,
          score: score,
        );
    if (mounted) Navigator.pop(context);
  }
}

