import 'package:cloud_firestore/cloud_firestore.dart';

enum QuizType { short, long }

extension QuizTypeExt on QuizType {
  String get label => this == QuizType.short ? 'short' : 'long';

  static QuizType fromString(String value) {
    switch (value) {
      case 'short':
        return QuizType.short;
      case 'long':
        return QuizType.long;
      default:
        return QuizType.short;
    }
  }
}

class Quiz {
  final String quizId;
  final String studentId;
  final DateTime date;
  final QuizType type;
  final int totalItems;
  final int score;

  Quiz({
    required this.quizId,
    required this.studentId,
    required this.date,
    required this.type,
    required this.totalItems,
    required this.score,
  });

  double get percentage => totalItems > 0 ? (score / totalItems) * 100 : 0;

  Quiz copyWith({
    String? quizId,
    String? studentId,
    DateTime? date,
    QuizType? type,
    int? totalItems,
    int? score,
  }) {
    return Quiz(
      quizId: quizId ?? this.quizId,
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

  factory Quiz.fromMap(String id, Map<String, dynamic> map) {
    return Quiz(
      quizId: id,
      studentId: map['studentId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      type: QuizTypeExt.fromString(map['type'] as String),
      totalItems: map['totalItems'] as int,
      score: map['score'] as int,
    );
  }

  factory Quiz.fromDocument(DocumentSnapshot doc) {
    return Quiz.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
