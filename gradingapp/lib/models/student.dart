import 'package:cloud_firestore/cloud_firestore.dart';

enum StudentSection { sectionA, sectionB }

extension StudentSectionExt on StudentSection {
  String get label => this == StudentSection.sectionA ? '3A' : '3B';

  static StudentSection fromString(String value) {
    switch (value) {
      case '3A':
        return StudentSection.sectionA;
      case '3B':
        return StudentSection.sectionB;
      default:
        return StudentSection.sectionA;
    }
  }
}

class Student {
  final String studentId;
  final String name;
  final String email;
  final StudentSection section;
  final DateTime createdAt;

  Student({
    required this.studentId,
    required this.name,
    required this.email,
    required this.section,
    required this.createdAt,
  });

  Student copyWith({
    String? studentId,
    String? name,
    String? email,
    StudentSection? section,
    DateTime? createdAt,
  }) {
    return Student(
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      email: email ?? this.email,
      section: section ?? this.section,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'section': section.label,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Student.fromMap(String id, Map<String, dynamic> map) {
    return Student(
      studentId: id,
      name: map['name'] as String,
      email: map['email'] as String,
      section: StudentSectionExt.fromString(map['section'] as String),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory Student.fromDocument(DocumentSnapshot doc) {
    return Student.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
