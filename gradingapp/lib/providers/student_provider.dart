import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import '../services/student_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final studentServiceProvider =
    Provider<StudentService>((ref) => StudentService());

// ── Filter state ──────────────────────────────────────────────────────────────

/// null = show all sections
final sectionFilterProvider = StateProvider<StudentSection?>((ref) => null);

/// Search query for student name
final studentSearchQueryProvider = StateProvider<String>((ref) => '');

// ── Stream provider ───────────────────────────────────────────────────────────

final studentsStreamProvider = StreamProvider<List<Student>>((ref) {
  final service = ref.watch(studentServiceProvider);
  final section = ref.watch(sectionFilterProvider);

  if (section != null) {
    return service.watchStudentsBySection(section);
  }
  return service.watchAllStudents();
});

// ── Filtered (search) derived provider ───────────────────────────────────────

final filteredStudentsProvider = Provider<AsyncValue<List<Student>>>((ref) {
  final students = ref.watch(studentsStreamProvider);
  final query = ref.watch(studentSearchQueryProvider).toLowerCase().trim();

  return students.whenData((list) {
    if (query.isEmpty) return list;
    return list
        .where((s) => s.name.toLowerCase().contains(query))
        .toList();
  });
});

// ── Single student provider ───────────────────────────────────────────────────

final studentProvider =
    FutureProvider.family<Student?, String>((ref, studentId) async {
  final service = ref.watch(studentServiceProvider);
  return service.getStudent(studentId);
});

// ── Mutation notifier ─────────────────────────────────────────────────────────

class StudentNotifier extends AsyncNotifier<void> {
  StudentService get _service => ref.read(studentServiceProvider);

  @override
  Future<void> build() async {}

  Future<void> addStudent({
    required String name,
    required String email,
    required StudentSection section,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final student = Student(
        studentId: '',
        name: name,
        email: email,
        section: section,
        createdAt: DateTime.now(),
      );
      await _service.addStudent(student);
    });
  }

  Future<void> updateStudent(Student student) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.updateStudent(student));
  }

  Future<void> deleteStudent(String studentId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.deleteStudent(studentId));
  }
}

final studentNotifierProvider =
    AsyncNotifierProvider<StudentNotifier, void>(StudentNotifier.new);
