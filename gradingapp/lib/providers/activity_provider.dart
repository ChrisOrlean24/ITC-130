import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final activityServiceProvider =
    Provider<ActivityService>((ref) => ActivityService());

// ── Stream provider (scoped per student) ─────────────────────────────────────

final activityStreamProvider =
    StreamProvider.family<List<Activity>, String>((ref, studentId) {
  final service = ref.watch(activityServiceProvider);
  return service.watchActivities(studentId);
});

// ── Average score derived provider ───────────────────────────────────────────

final activityAverageScoreProvider =
    Provider.family<double, String>((ref, studentId) {
  final activities =
      ref.watch(activityStreamProvider(studentId)).valueOrNull ?? [];
  final service = ref.read(activityServiceProvider);
  return service.computeAverageScore(activities);
});

// ── Mutation notifier ─────────────────────────────────────────────────────────

class ActivityNotifier extends FamilyAsyncNotifier<void, String> {
  ActivityService get _service => ref.read(activityServiceProvider);

  @override
  Future<void> build(String studentId) async {}

  Future<void> addActivity({
    required DateTime date,
    required int totalPoints,
    required int score,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final activity = Activity(
        activityId: '',
        studentId: arg,
        date: date,
        totalPoints: totalPoints,
        score: score,
      );
      await _service.addActivity(activity);
    });
  }

  Future<void> updateActivity(Activity activity) async {
    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => _service.updateActivity(activity));
  }

  Future<void> deleteActivity(String activityId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _service.deleteActivity(arg, activityId));
  }
}

final activityNotifierProvider =
    AsyncNotifierProviderFamily<ActivityNotifier, void, String>(
        ActivityNotifier.new);
