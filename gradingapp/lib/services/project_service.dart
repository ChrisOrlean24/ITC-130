import '../models/project.dart';
import 'firestore_service.dart';

class ProjectService {
  // ── Read ─────────────────────────────────────────────────────────────────
  Stream<List<Project>> watchProjects(String studentId) {
    return FirestoreService.projects(studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Project.fromDocument(doc)).toList());
  }

  double computeAverageScore(List<Project> projects) {
    if (projects.isEmpty) return 0;
    final total = projects.fold<double>(0, (sum, project) => sum + project.percentage);
    return total / projects.length;
  }

  // ── Create ───────────────────────────────────────────────────────────────
  Future<void> addProject(Project project) async {
    await FirestoreService.projects(project.studentId).add(project.toMap());
  }

  // ── Update ─────────────────────────────────────────────────────────────────
  Future<void> updateProject(Project project) async {
    await FirestoreService.projects(project.studentId)
        .doc(project.projectId)
        .update(project.toMap());
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  Future<void> deleteProject(String studentId, String projectId) async {
    await FirestoreService.projects(studentId).doc(projectId).delete();
  }
}
