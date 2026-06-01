import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/oral_recitation.dart';
import '../services/oral_recitation_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final oralRecitationServiceProvider =
    Provider<OralRecitationService>((ref) => OralRecitationService());

// ── Stream provider (scoped per student) ─────────────────────────────────────

final oralRecitationStreamProvider =
    StreamProvider.family<List<OralRecitation>, String>((ref, studentId) {
  final service = ref.watch(oralRecitationServiceProvider);
  return service.watchOralRecitations(studentId);
});

// ── Score derived provider ────────────────────────────────────────────────────

final oralRecitationScoreProvider =
    Provider.family<double, String>((ref, studentId) {
  final records =
      ref.watch(oralRecitationStreamProvider(studentId)).valueOrNull ?? [];
  final service = ref.read(oralRecitationServiceProvider);
  return service.computeScore(records);
});

// ── Mutation notifier ─────────────────────────────────────────────────────────

class OralRecitationNotifier extends FamilyAsyncNotifier<void, String> {
  OralRecitationService get _service =>
      ref.read(oralRecitationServiceProvider);

  @override
  Future<void> build(String studentId) async {}

  Future<void> addOralRecitation({
    required DateTime date,
    required int points,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final record = OralRecitation(
        oralId: '',
        studentId: arg,
        date: date,
        points: points,
      );
      await _service.addOralRecitation(record);
    });
  }

  Future<void> updateOralRecitation(OralRecitation record) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _service.updateOralRecitation(record));
  }

  Future<void> deleteOralRecitation(String oralId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _service.deleteOralRecitation(arg, oralId));
  }
}

final oralRecitationNotifierProvider =
    AsyncNotifierProviderFamily<OralRecitationNotifier, void, String>(
        OralRecitationNotifier.new);
