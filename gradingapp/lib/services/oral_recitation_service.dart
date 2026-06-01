import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/oral_recitation.dart';
import 'firestore_service.dart';

class OralRecitationService {
  CollectionReference<Map<String, dynamic>> _col(String studentId) =>
      FirestoreService.oralRecitations(studentId);

  // ── Create ───────────────────────────────────────────────────────────────

  Future<OralRecitation> addOralRecitation(OralRecitation record) async {
    final ref = await _col(record.studentId).add(record.toMap());
    return record.copyWith(oralId: ref.id);
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  Stream<List<OralRecitation>> watchOralRecitations(String studentId) {
    return _col(studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OralRecitation.fromDocument).toList());
  }

  // ── Update ───────────────────────────────────────────────────────────────

  Future<void> updateOralRecitation(OralRecitation record) async {
    await _col(record.studentId).doc(record.oralId).update(record.toMap());
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteOralRecitation(String studentId, String oralId) async {
    await _col(studentId).doc(oralId).delete();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns total points earned as a percentage of a configurable max.
  double computeScore(List<OralRecitation> records, {int maxPoints = 100}) {
    if (records.isEmpty) return 0;
    final total = records.fold<int>(0, (acc, r) => acc + r.points);
    return (total / maxPoints).clamp(0, 1) * 100;
  }
}
