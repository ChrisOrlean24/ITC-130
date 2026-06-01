import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { present, absent, late }

extension AttendanceStatusExt on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.late:
        return 'late';
    }
  }

  static AttendanceStatus fromString(String value) {
    switch (value) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus.absent;
    }
  }
}

class Attendance {
  final String attendanceId;
  final String studentId;
  final DateTime date;
  final AttendanceStatus status;

  Attendance({
    required this.attendanceId,
    required this.studentId,
    required this.date,
    required this.status,
  });

  Attendance copyWith({
    String? attendanceId,
    String? studentId,
    DateTime? date,
    AttendanceStatus? status,
  }) {
    return Attendance(
      attendanceId: attendanceId ?? this.attendanceId,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(date),
      'status': status.label,
    };
  }

  factory Attendance.fromMap(String id, Map<String, dynamic> map) {
    return Attendance(
      attendanceId: id,
      studentId: map['studentId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      status: AttendanceStatusExt.fromString(map['status'] as String),
    );
  }

  factory Attendance.fromDocument(DocumentSnapshot doc) {
    return Attendance.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
