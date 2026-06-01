import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../providers/oral_recitation_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/grading/grade_entry_tile.dart';
import '../../widgets/common/form_helpers.dart';

class OralRecitationScreen extends ConsumerWidget {
  final String studentId;
  const OralRecitationScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync =
        ref.watch(oralRecitationStreamProvider(studentId));
    final score = ref.watch(oralRecitationScoreProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oral Recitation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (score > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'Score: ${score.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: AppTheme.gradeColor(score),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: recordsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(
              icon: Icons.record_voice_over_outlined,
              title: 'No recitations yet',
              subtitle: 'Tap + to add recitation points.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = records[i];
              return GradeEntryTile(
                date: r.date,
                label: 'Recitation',
                label2: '${r.points} pts',
                onDelete: () => ref
                    .read(oralRecitationNotifierProvider(studentId)
                        .notifier)
                    .deleteOralRecitation(r.oralId),
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
      builder: (_) => _OralSheet(studentId: studentId),
    );
  }
}

class _OralSheet extends ConsumerStatefulWidget {
  final String studentId;
  const _OralSheet({required this.studentId});

  @override
  ConsumerState<_OralSheet> createState() => _OralSheetState();
}

class _OralSheetState extends ConsumerState<_OralSheet> {
  final _pointsController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _pointsController.dispose();
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
          Text('Add Recitation', style: AppTheme.headlineMedium),
          const SizedBox(height: 20),
          DateRow(
              date: _date, onChanged: (d) => setState(() => _date = d)),
          const SizedBox(height: 16),
          AppTextField(
            controller: _pointsController,
            label: 'Points earned',
            hint: '5',
            keyboardType: TextInputType.number,
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
    final points = int.tryParse(_pointsController.text);
    if (points == null) return;

    setState(() => _loading = true);
    await ref
        .read(oralRecitationNotifierProvider(widget.studentId).notifier)
        .addOralRecitation(date: _date, points: points);
    if (mounted) Navigator.pop(context);
  }
}
