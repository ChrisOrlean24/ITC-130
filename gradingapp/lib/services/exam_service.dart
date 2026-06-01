import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exam.dart';
import 'firestore_service.dart';

class ExamService {
  CollectionReference<Map<String, dynamic>> _col(String studentId) =>
      FirestoreService.exams(studentId);

  // ── Create ───────────────────────────────────────────────────────────────

  Future<Exam> addExam(Exam exam) async {
    final ref = await _col(exam.studentId).add(exam.toMap());
    return exam.copyWith(examId: ref.id);
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  Stream<List<Exam>> watchExams(String studentId) {
    return _col(studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Exam.fromDocument).toList());
  }

  Future<Exam?> getExamByType(String studentId, ExamType type) async {
    final snap = await _col(studentId)
        .where('type', isEqualTo: type.label)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return Exam.fromDocument(snap.docs.first);
  }

  // ── Update ───────────────────────────────────────────────────────────────

  Future<void> updateExam(Exam exam) async {
    await _col(exam.studentId).doc(exam.examId).update(exam.toMap());
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteExam(String studentId, String examId) async {
    await _col(studentId).doc(examId).delete();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Score for a specific exam type. Returns 0 if no record found.
  double scoreForType(List<Exam> exams, ExamType type) {
    final match = exams.where((e) => e.type == type);
    if (match.isEmpty) return 0;
    // If multiple records exist, take the latest (highest percentage)
    return match.map((e) => e.percentage).reduce((a, b) => a > b ? a : b);
  }
}
