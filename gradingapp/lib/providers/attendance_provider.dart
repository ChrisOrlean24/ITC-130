import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final attendanceServiceProvider =
    Provider<AttendanceService>((ref) => AttendanceService());

// ── Stream provider (scoped per student) ─────────────────────────────────────

final attendanceStreamProvider =
    StreamProvider.family<List<Attendance>, String>((ref, studentId) {
  final service = ref.watch(attendanceServiceProvider);
  return service.watchAttendance(studentId);
});

// ── Attendance score derived provider ────────────────────────────────────────

final attendanceScoreProvider =
    Provider.family<double, String>((ref, studentId) {
  final attendance =
      ref.watch(attendanceStreamProvider(studentId)).valueOrNull ?? [];
  final service = ref.read(attendanceServiceProvider);
  return service.computeAttendanceScore(attendance);
});

// ── Mutation notifier ─────────────────────────────────────────────────────────

class AttendanceNotifier extends FamilyAsyncNotifier<void, String> {
  AttendanceService get _service => ref.read(attendanceServiceProvider);

  @override
  Future<void> build(String studentId) async {}

  Future<void> addAttendance({
    required DateTime date,
    required AttendanceStatus status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final record = Attendance(
        attendanceId: '',
        studentId: arg,
        date: date,
        status: status,
      );
      await _service.addAttendance(record);
    });
  }

  Future<void> updateAttendance(Attendance attendance) async {
    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => _service.updateAttendance(attendance));
  }

  Future<void> deleteAttendance(String attendanceId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _service.deleteAttendance(arg, attendanceId));
  }
}

final attendanceNotifierProvider =
    AsyncNotifierProviderFamily<AttendanceNotifier, void, String>(
        AttendanceNotifier.new);
