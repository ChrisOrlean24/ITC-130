import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

enum GradeBadgeSize { small, medium, large }

class GradeBadge extends StatelessWidget {
  final double grade;
  final GradeBadgeSize size;

  const GradeBadge({
    super.key,
    required this.grade,
    this.size = GradeBadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.gradeColor(grade);
    final hasGrade = grade > 0;

    final (double boxSize, double fontSize, double subFontSize) = switch (size) {
      GradeBadgeSize.small => (44.0, 13.0, 9.0),
      GradeBadgeSize.medium => (56.0, 16.0, 10.0),
      GradeBadgeSize.large => (72.0, 22.0, 11.0),
    };

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: hasGrade ? color.withOpacity(0.12) : AppTheme.surfaceElevated,
        shape: BoxShape.circle,
        border: Border.all(
          color: hasGrade ? color.withOpacity(0.4) : AppTheme.divider,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hasGrade ? grade.toStringAsFixed(0) : '—',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: hasGrade ? color : AppTheme.textMuted,
              height: 1,
            ),
          ),
          if (hasGrade && size != GradeBadgeSize.small) ...[
            const SizedBox(height: 1),
            Text(
              '%',
              style: TextStyle(
                fontSize: subFontSize,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
