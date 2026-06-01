import 'package:cloud_firestore/cloud_firestore.dart';

enum ExamType { prelim, midterm, finals }

extension ExamTypeExt on ExamType {
  String get label {
    switch (this) {
      case ExamType.prelim:
        return 'prelim';
      case ExamType.midterm:
        return 'midterm';
      case ExamType.finals:
        return 'finals';
    }
  }

  static ExamType fromString(String value) {
    switch (value) {
      case 'prelim':
        return ExamType.prelim;
      case 'midterm':
        return ExamType.midterm;
      case 'finals':
        return ExamType.finals;
      default:
        return ExamType.prelim;
    }
  }
}

class Exam {
  final String examId;
  final String studentId;
  final DateTime date;
  final ExamType type;
  final int totalItems;
  final int score;

  Exam({
    required this.examId,
    required this.studentId,
    required this.date,
    required this.type,
    required this.totalItems,
    required this.score,
  });

  double get percentage => totalItems > 0 ? (score / totalItems) * 100 : 0;

  Exam copyWith({
    String? examId,
    String? studentId,
    DateTime? date,
    ExamType? type,
    int? totalItems,
    int? score,
  }) {
    return Exam(
      examId: examId ?? this.examId,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      type: type ?? this.type,
      totalItems: totalItems ?? this.totalItems,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'type': type.label,
      'totalItems': totalItems,
      'score': score,
    };
  }

  factory Exam.fromMap(String id, Map<String, dynamic> map) {
    return Exam(
      examId: id,
      studentId: map['studentId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      type: ExamTypeExt.fromString(map['type'] as String),
      totalItems: map['totalItems'] as int,
      score: map['score'] as int,
    );
  }

  factory Exam.fromDocument(DocumentSnapshot doc) {
    return Exam.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
