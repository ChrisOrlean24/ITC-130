import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exam.dart';
import '../services/exam_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final examServiceProvider = Provider<ExamService>((ref) => ExamService());

// ── Stream provider (scoped per student) ─────────────────────────────────────

final examStreamProvider =
    StreamProvider.family<List<Exam>, String>((ref, studentId) {
  final service = ref.watch(examServiceProvider);
  return service.watchExams(studentId);
});

// ── Per-type score derived providers ─────────────────────────────────────────

final prelimScoreProvider =
    Provider.family<double, String>((ref, studentId) {
  final exams = ref.watch(examStreamProvider(studentId)).valueOrNull ?? [];
  final service = ref.read(examServiceProvider);
  return service.scoreForType(exams, ExamType.prelim);
});

final midtermScoreProvider =
    Provider.family<double, String>((ref, studentId) {
  final exams = ref.watch(examStreamProvider(studentId)).valueOrNull ?? [];
  final service = ref.read(examServiceProvider);
  return service.scoreForType(exams, ExamType.midterm);
});

final finalsScoreProvider =
    Provider.family<double, String>((ref, studentId) {
  final exams = ref.watch(examStreamProvider(studentId)).valueOrNull ?? [];
  final service = ref.read(examServiceProvider);
  return service.scoreForType(exams, ExamType.finals);
});

// ── Mutation notifier ─────────────────────────────────────────────────────────

class ExamNotifier extends FamilyAsyncNotifier<void, String> {
  ExamService get _service => ref.read(examServiceProvider);

  @override
  Future<void> build(String studentId) async {}

  Future<void> addExam({
    required DateTime date,
    required ExamType type,
    required int totalItems,
    required int score,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final exam = Exam(
        examId: '',
        studentId: arg,
        date: date,
        type: type,
        totalItems: totalItems,
        score: score,
      );
      await _service.addExam(exam);
    });
  }

  Future<void> updateExam(Exam exam) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.updateExam(exam));
  }

  Future<void> deleteExam(String examId) async {
    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => _service.deleteExam(arg, examId));
  }
}

final examNotifierProvider =
    AsyncNotifierProviderFamily<ExamNotifier, void, String>(
        ExamNotifier.new);
