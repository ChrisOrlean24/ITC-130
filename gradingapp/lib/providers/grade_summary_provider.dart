import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grade_summary.dart';
import 'attendance_provider.dart';
import 'quiz_provider.dart';
import 'exam_provider.dart';
import 'activity_provider.dart';
import 'oral_recitation_provider.dart';
import 'project_provider.dart';

// ── Configurable weights (global, can be overridden per teacher session) ──────

final gradeWeightsProvider = StateProvider<GradeWeights>(
  (ref) => GradeWeights.defaults(),
);

// ── Grade summary for a single student ───────────────────────────────────────

/// Watches all component score providers for a given student and
/// assembles a [GradeSummary] reactively. Automatically recomputes
/// whenever any upstream score changes.
final gradeSummaryProvider =
    Provider.family<GradeSummary, String>((ref, studentId) {
  final weights = ref.watch(gradeWeightsProvider);

  final attendanceScore = ref.watch(attendanceScoreProvider(studentId));
  final quizScore = ref.watch(quizAverageScoreProvider(studentId));
  final activityScore = ref.watch(activityAverageScoreProvider(studentId));
  final oralScore = ref.watch(oralRecitationScoreProvider(studentId));
  final projectScore = ref.watch(projectAverageScoreProvider(studentId));
  final prelimScore = ref.watch(prelimScoreProvider(studentId));
  final midtermScore = ref.watch(midtermScoreProvider(studentId));
  final finalsScore = ref.watch(finalsScoreProvider(studentId));

  return GradeSummary(
    studentId: studentId,
    attendanceScore: attendanceScore,
    quizScore: quizScore,
    activityScore: activityScore,
    oralRecitationScore: oralScore,
    projectScore: projectScore,
    prelimScore: prelimScore,
    midtermScore: midtermScore,
    finalsScore: finalsScore,
    weights: weights,
  );
});

// ── Grade breakdown for UI display ───────────────────────────────────────────

/// Returns each grade component as a labeled entry for easy rendering
/// in the grade summary screen.
final gradeBreakdownProvider =
    Provider.family<List<GradeBreakdownEntry>, String>((ref, studentId) {
  final summary = ref.watch(gradeSummaryProvider(studentId));
  final weights = summary.weights;

  return [
    GradeBreakdownEntry(
      label: 'Attendance',
      rawScore: summary.attendanceScore,
      weight: weights.attendance,
    ),
    GradeBreakdownEntry(
      label: 'Quizzes',
      rawScore: summary.quizScore,
      weight: weights.quiz,
    ),
    GradeBreakdownEntry(
      label: 'Activities',
      rawScore: summary.activityScore,
      weight: weights.activity,
    ),
    GradeBreakdownEntry(
      label: 'Oral Recitation',
      rawScore: summary.oralRecitationScore,
      weight: weights.oralRecitation,
    ),
    GradeBreakdownEntry(
      label: 'Projects',
      rawScore: summary.projectScore,
      weight: weights.project,
    ),
    GradeBreakdownEntry(
      label: 'Prelim Exam',
      rawScore: summary.prelimScore,
      weight: weights.prelim,
    ),
    GradeBreakdownEntry(
      label: 'Midterm Exam',
      rawScore: summary.midtermScore,
      weight: weights.midterm,
    ),
    GradeBreakdownEntry(
      label: 'Final Exam',
      rawScore: summary.finalsScore,
      weight: weights.finals,
    ),
  ];
});

// ── Helper model for breakdown display ───────────────────────────────────────

class GradeBreakdownEntry {
  final String label;

  /// Raw score 0–100 for this component
  final double rawScore;

  /// Weight as a decimal (e.g. 0.20 = 20%)
  final double weight;

  const GradeBreakdownEntry({
    required this.label,
    required this.rawScore,
    required this.weight,
  });

  /// Weighted contribution to final grade
  double get weightedScore => rawScore * weight;

  String get weightLabel => '${(weight * 100).toStringAsFixed(0)}%';
}
