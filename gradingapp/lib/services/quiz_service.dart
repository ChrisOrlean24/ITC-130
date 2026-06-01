import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';
import 'firestore_service.dart';

class QuizService {
  CollectionReference<Map<String, dynamic>> _col(String studentId) =>
      FirestoreService.quizzes(studentId);

  // ── Create ───────────────────────────────────────────────────────────────

  Future<Quiz> addQuiz(Quiz quiz) async {
    final ref = await _col(quiz.studentId).add(quiz.toMap());
    return quiz.copyWith(quizId: ref.id);
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  Stream<List<Quiz>> watchQuizzes(String studentId) {
    return _col(studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Quiz.fromDocument).toList());
  }

  Stream<List<Quiz>> watchQuizzesByType(String studentId, QuizType type) {
    return _col(studentId)
        .where('type', isEqualTo: type.label)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Quiz.fromDocument).toList());
  }

  // ── Update ───────────────────────────────────────────────────────────────

  Future<void> updateQuiz(Quiz quiz) async {
    await _col(quiz.studentId).doc(quiz.quizId).update(quiz.toMap());
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteQuiz(String studentId, String quizId) async {
    await _col(studentId).doc(quizId).delete();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Average percentage score across all quizzes (0–100).
  double computeAverageScore(List<Quiz> quizzes) {
    if (quizzes.isEmpty) return 0;
    final total = quizzes.fold<double>(0, (acc, q) => acc + q.percentage);
    return total / quizzes.length;
  }
}
