import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String activityId;
  final String studentId;
  final DateTime date;
  final int totalPoints;
  final int score;

  Activity({
    required this.activityId,
    required this.studentId,
    required this.date,
    required this.totalPoints,
    required this.score,
  });

  double get percentage => totalPoints > 0 ? (score / totalPoints) * 100 : 0;

  Activity copyWith({
    String? activityId,
    String? studentId,
    DateTime? date,
    int? totalPoints,
    int? score,
  }) {
    return Activity(
      activityId: activityId ?? this.activityId,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      totalPoints: totalPoints ?? this.totalPoints,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'totalPoints': totalPoints,
      'score': score,
    };
  }

  factory Activity.fromMap(String id, Map<String, dynamic> map) {
    return Activity(
      activityId: id,
      studentId: map['studentId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      totalPoints: map['totalPoints'] as int,
      score: map['score'] as int,
    );
  }

  factory Activity.fromDocument(DocumentSnapshot doc) {
    return Activity.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
