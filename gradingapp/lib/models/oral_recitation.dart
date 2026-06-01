import 'package:cloud_firestore/cloud_firestore.dart';

class OralRecitation {
  final String oralId;
  final String studentId;
  final DateTime date;
  final int points;

  OralRecitation({
    required this.oralId,
    required this.studentId,
    required this.date,
    required this.points,
  });

  OralRecitation copyWith({
    String? oralId,
    String? studentId,
    DateTime? date,
    int? points,
  }) {
    return OralRecitation(
      oralId: oralId ?? this.oralId,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'points': points,
    };
  }

  factory OralRecitation.fromMap(String id, Map<String, dynamic> map) {
    return OralRecitation(
      oralId: id,
      studentId: map['studentId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      points: map['points'] as int,
    );
  }

  factory OralRecitation.fromDocument(DocumentSnapshot doc) {
    return OralRecitation.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
