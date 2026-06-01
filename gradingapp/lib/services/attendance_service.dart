import '../models/attendance.dart';
import 'firestore_service.dart';

class AttendanceService {
  // ── Read ─────────────────────────────────────────────────────────────────
  Stream<List<Attendance>> watchAttendance(String studentId) {
    return FirestoreService.attendance(studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Attendance.fromDocument(doc)).toList());
  }

  double computeAttendanceScore(List<Attendance> attendance) {
    if (attendance.isEmpty) return 0;
    final presentCount = attendance
        .where((record) => record.status == AttendanceStatus.present)
        .length;
    return (presentCount / attendance.length) * 100;
  }

  // ── Create ───────────────────────────────────────────────────────────────
  Future<void> addAttendance(Attendance attendance) async {
    await FirestoreService.attendance(attendance.studentId)
        .add(attendance.toMap());
  }

  // ── Update ─────────────────────────────────────────────────────────────────
  Future<void> updateAttendance(Attendance attendance) async {
    await FirestoreService.attendance(attendance.studentId)
        .doc(attendance.attendanceId)
        .update(attendance.toMap());
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  Future<void> deleteAttendance(String studentId, String attendanceId) async {
    await FirestoreService.attendance(studentId)
        .doc(attendanceId)
        .delete();
  }
}
