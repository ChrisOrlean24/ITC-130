import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String projectId;
  final String studentId;
  final DateTime date;
  final int totalPoints;
  final int score;

  Project({
    required this.projectId,
    required this.studentId,
    required this.date,
    required this.totalPoints,
    required this.score,
  });

  double get percentage => totalPoints > 0 ? (score / totalPoints) * 100 : 0;

  Project copyWith({
    String? projectId,
    String? studentId,
    DateTime? date,
    int? totalPoints,
    int? score,
  }) {
    return Project(
      projectId: projectId ?? this.projectId,
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

  factory Project.fromMap(String id, Map<String, dynamic> map) {
    return Project(
      projectId: id,
      studentId: map['studentId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      totalPoints: map['totalPoints'] as int,
      score: map['score'] as int,
    );
  }

  factory Project.fromDocument(DocumentSnapshot doc) {
    return Project.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
