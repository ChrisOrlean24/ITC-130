import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/grading/grade_entry_tile.dart';

class AttendanceScreen extends ConsumerWidget {
  final String studentId;
  const AttendanceScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceStreamProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: attendanceAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(
              icon: Icons.calendar_today_outlined,
              title: 'No attendance yet',
              subtitle: 'Tap + to record attendance.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = records[i];
              final statusLabel = r.status.label[0].toUpperCase() +
                  r.status.label.substring(1);
              final color = r.status == AttendanceStatus.present
                  ? AppTheme.success
                  : r.status == AttendanceStatus.late
                      ? AppTheme.warning
                      : AppTheme.error;
              return GradeEntryTile(
                date: r.date,
                label: 'Attendance',
                labelColor: statusLabel,
                labelColorValue: color,
                onDelete: () => ref
                    .read(attendanceNotifierProvider(studentId).notifier)
                    .deleteAttendance(r.attendanceId),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AttendanceSheet(studentId: studentId),
    );
  }
}

class _AttendanceSheet extends ConsumerStatefulWidget {
  final String studentId;
  const _AttendanceSheet({required this.studentId});

  @override
  ConsumerState<_AttendanceSheet> createState() => _AttendanceSheetState();
}

class _AttendanceSheetState extends ConsumerState<_AttendanceSheet> {
  DateTime _date = DateTime.now();
  AttendanceStatus _status = AttendanceStatus.present;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Record Attendance', style: AppTheme.headlineMedium),
          const SizedBox(height: 20),
          _DatePickerRow(
            date: _date,
            onChanged: (d) => setState(() => _date = d),
          ),
          const SizedBox(height: 16),
          Row(
            children: AttendanceStatus.values.map((s) {
              final isSelected = _status == s;
              final color = s == AttendanceStatus.present
                  ? AppTheme.success
                  : s == AttendanceStatus.late
                      ? AppTheme.warning
                      : AppTheme.error;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.15)
                            : AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : AppTheme.divider,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          s.label[0].toUpperCase() + s.label.substring(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? color : AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      await ref
                          .read(attendanceNotifierProvider(
                                  widget.studentId)
                              .notifier)
                          .addAttendance(date: _date, status: _status);
                      if (context.mounted) Navigator.pop(context);
                    },
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
}

class _DatePickerRow extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;
  const _DatePickerRow({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppTheme.accent),
            const SizedBox(width: 10),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
