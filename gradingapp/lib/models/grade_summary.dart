/// Holds the computed final grade breakdown for a single student.
class GradeSummary {
  final String studentId;

  // Component averages (0–100)
  final double attendanceScore;
  final double quizScore;
  final double activityScore;
  final double oralRecitationScore;
  final double projectScore;
  final double prelimScore;
  final double midtermScore;
  final double finalsScore;

  // Configurable weights (must sum to 1.0)
  final GradeWeights weights;

  GradeSummary({
    required this.studentId,
    required this.attendanceScore,
    required this.quizScore,
    required this.activityScore,
    required this.oralRecitationScore,
    required this.projectScore,
    required this.prelimScore,
    required this.midtermScore,
    required this.finalsScore,
    GradeWeights? weights,
  }) : weights = weights ?? GradeWeights.defaults();

  /// Weighted final grade (0–100)
  double get finalGrade {
    return (attendanceScore * weights.attendance) +
        (quizScore * weights.quiz) +
        (activityScore * weights.activity) +
        (oralRecitationScore * weights.oralRecitation) +
        (projectScore * weights.project) +
        (prelimScore * weights.prelim) +
        (midtermScore * weights.midterm) +
        (finalsScore * weights.finals);
  }

  String get remarks {
    final g = finalGrade;
    if (g >= 90) return 'Excellent';
    if (g >= 85) return 'Very Good';
    if (g >= 80) return 'Good';
    if (g >= 75) return 'Passing';
    return 'Failed';
  }

  bool get isPassing => finalGrade >= 75;
}

class GradeWeights {
  final double attendance;
  final double quiz;
  final double activity;
  final double oralRecitation;
  final double project;
  final double prelim;
  final double midterm;
  final double finals;

  const GradeWeights({
    required this.attendance,
    required this.quiz,
    required this.activity,
    required this.oralRecitation,
    required this.project,
    required this.prelim,
    required this.midterm,
    required this.finals,
  });

  /// Default weights — adjust to match your school's policy
  factory GradeWeights.defaults() => const GradeWeights(
        attendance: 0.10,
        quiz: 0.20,
        activity: 0.10,
        oralRecitation: 0.10,
        project: 0.10,
        prelim: 0.15,
        midterm: 0.10,
        finals: 0.15,
      );

  /// Validates that all weights sum to exactly 1.0
  bool get isValid {
    final sum = attendance + quiz + activity + oralRecitation + project + prelim + midterm + finals;
    return (sum - 1.0).abs() < 0.001;
  }
}
