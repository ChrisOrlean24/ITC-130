import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity.dart';
import 'firestore_service.dart';

class ActivityService {
  CollectionReference<Map<String, dynamic>> _col(String studentId) =>
      FirestoreService.activities(studentId);

  // ── Create ───────────────────────────────────────────────────────────────

  Future<Activity> addActivity(Activity activity) async {
    final ref = await _col(activity.studentId).add(activity.toMap());
    return activity.copyWith(activityId: ref.id);
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  Stream<List<Activity>> watchActivities(String studentId) {
    return _col(studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Activity.fromDocument).toList());
  }

  // ── Update ───────────────────────────────────────────────────────────────

  Future<void> updateActivity(Activity activity) async {
    await _col(activity.studentId)
        .doc(activity.activityId)
        .update(activity.toMap());
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteActivity(String studentId, String activityId) async {
    await _col(studentId).doc(activityId).delete();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  double computeAverageScore(List<Activity> activities) {
    if (activities.isEmpty) return 0;
    final total = activities.fold<double>(0, (acc, a) => acc + a.percentage);
    return total / activities.length;
  }
}
