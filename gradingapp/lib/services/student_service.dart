import '../models/student.dart';
import 'firestore_service.dart';

class StudentService {
  final _col = FirestoreService.students;

  // ── Create ───────────────────────────────────────────────────────────────

  Future<Student> addStudent(Student student) async {
    final ref = await _col.add(student.toMap());
    return student.copyWith(studentId: ref.id);
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  Stream<List<Student>> watchAllStudents() {
    return _col.orderBy('name').snapshots().map(
          (snap) => snap.docs.map(Student.fromDocument).toList(),
        );
  }

  Stream<List<Student>> watchStudentsBySection(StudentSection section) {
    return _col
        .where('section', isEqualTo: section.label)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(Student.fromDocument).toList());
  }

  Future<Student?> getStudent(String studentId) async {
    final doc = await _col.doc(studentId).get();
    if (!doc.exists) return null;
    return Student.fromDocument(doc);
  }

  // ── Update ───────────────────────────────────────────────────────────────

  Future<void> updateStudent(Student student) async {
    await _col.doc(student.studentId).update(student.toMap());
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  /// Deletes the student document. Subcollection cleanup should be handled
  /// via a Cloud Function in production to avoid large client-side batch ops.
  Future<void> deleteStudent(String studentId) async {
    await _col.doc(studentId).delete();
  }
}
