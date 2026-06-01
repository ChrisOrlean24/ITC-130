import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final quizServiceProvider = Provider<QuizService>((ref) => QuizService());

// ── Stream provider (scoped per student) ─────────────────────────────────────

final quizStreamProvider =
    StreamProvider.family<List<Quiz>, String>((ref, studentId) {
  final service = ref.watch(quizServiceProvider);
  return service.watchQuizzes(studentId);
});

// ── Average score derived provider ───────────────────────────────────────────

final quizAverageScoreProvider =
    Provider.family<double, String>((ref, studentId) {
  final quizzes =
      ref.watch(quizStreamProvider(studentId)).valueOrNull ?? [];
  final service = ref.read(quizServiceProvider);
  return service.computeAverageScore(quizzes);
});

// ── Mutation notifier ─────────────────────────────────────────────────────────

class QuizNotifier extends FamilyAsyncNotifier<void, String> {
  QuizService get _service => ref.read(quizServiceProvider);

  @override
  Future<void> build(String studentId) async {}

  Future<void> addQuiz({
    required DateTime date,
    required QuizType type,
    required int totalItems,
    required int score,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final quiz = Quiz(
        quizId: '',
        studentId: arg,
        date: date,
        type: type,
        totalItems: totalItems,
        score: score,
      );
      await _service.addQuiz(quiz);
    });
  }

  Future<void> updateQuiz(Quiz quiz) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.updateQuiz(quiz));
  }

  Future<void> deleteQuiz(String quizId) async {
    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => _service.deleteQuiz(arg, quizId));
  }
}

final quizNotifierProvider =
    AsyncNotifierProviderFamily<QuizNotifier, void, String>(
        QuizNotifier.new);
