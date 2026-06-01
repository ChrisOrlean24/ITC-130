import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class GradeEntryTile extends StatelessWidget {
  final DateTime date;
  final String label;
  final String? label2;
  final int? score;
  final int? total;
  final double? percentage;
  final String? labelColor;
  final Color? labelColorValue;
  final VoidCallback onDelete;

  const GradeEntryTile({
    super.key,
    required this.date,
    required this.label,
    this.label2,
    this.score,
    this.total,
    this.percentage,
    this.labelColor,
    this.labelColorValue,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final pct = percentage;
    final scoreColor = pct != null ? AppTheme.gradeColor(pct) : AppTheme.accent;

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    _monthAbbr(date.month),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (label2 != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      label2!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (score != null && total != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$score/$total',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    '${pct?.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            if (labelColor != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (labelColorValue ?? AppTheme.accent).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  labelColor!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: labelColorValue ?? AppTheme.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _monthAbbr(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }
}
