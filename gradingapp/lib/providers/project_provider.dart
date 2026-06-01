import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../services/project_service.dart';

// ── Service provider ──────────────────────────────────────────────────────────

final projectServiceProvider =
    Provider<ProjectService>((ref) => ProjectService());

// ── Stream provider (scoped per student) ─────────────────────────────────────

final projectStreamProvider =
    StreamProvider.family<List<Project>, String>((ref, studentId) {
  final service = ref.watch(projectServiceProvider);
  return service.watchProjects(studentId);
});

// ── Average score derived provider ───────────────────────────────────────────

final projectAverageScoreProvider =
    Provider.family<double, String>((ref, studentId) {
  final projects =
      ref.watch(projectStreamProvider(studentId)).valueOrNull ?? [];
  final service = ref.read(projectServiceProvider);
  return service.computeAverageScore(projects);
});

// ── Mutation notifier ─────────────────────────────────────────────────────────

class ProjectNotifier extends FamilyAsyncNotifier<void, String> {
  ProjectService get _service => ref.read(projectServiceProvider);

  @override
  Future<void> build(String studentId) async {}

  Future<void> addProject({
    required DateTime date,
    required int totalPoints,
    required int score,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final project = Project(
        projectId: '',
        studentId: arg,
        date: date,
        totalPoints: totalPoints,
        score: score,
      );
      await _service.addProject(project);
    });
  }

  Future<void> updateProject(Project project) async {
    state = const AsyncLoading();
    state =
        await AsyncValue.guard(() => _service.updateProject(project));
  }

  Future<void> deleteProject(String projectId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _service.deleteProject(arg, projectId));
  }
}

final projectNotifierProvider =
    AsyncNotifierProviderFamily<ProjectNotifier, void, String>(
        ProjectNotifier.new);
