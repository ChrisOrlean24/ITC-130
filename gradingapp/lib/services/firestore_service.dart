import 'package:cloud_firestore/cloud_firestore.dart';

/// Shared Firestore instance and collection path helpers.
/// All feature services extend or use this as a base reference.
class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // ── Top-level collections ────────────────────────────────────────────────
  static CollectionReference<Map<String, dynamic>> get students =>
      db.collection('students');

  // ── Subcollection helpers (scoped under a student doc) ───────────────────
  static CollectionReference<Map<String, dynamic>> attendance(String studentId) =>
      students.doc(studentId).collection('attendance');

  static CollectionReference<Map<String, dynamic>> quizzes(String studentId) =>
      students.doc(studentId).collection('quizzes');

  static CollectionReference<Map<String, dynamic>> exams(String studentId) =>
      students.doc(studentId).collection('exams');

  static CollectionReference<Map<String, dynamic>> activities(String studentId) =>
      students.doc(studentId).collection('activities');

  static CollectionReference<Map<String, dynamic>> oralRecitations(String studentId) =>
      students.doc(studentId).collection('oral_recitations');

  static CollectionReference<Map<String, dynamic>> projects(String studentId) =>
      students.doc(studentId).collection('projects');
}
