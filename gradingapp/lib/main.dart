import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/app_theme.dart';
import 'utils/sqlite_init.dart';
import 'firebase_options.dart';
import 'screens/todo/todo_screen.dart';
import 'screens/todo/todo_form_screen.dart';
import 'screens/grading/student_list_screen.dart';
import 'screens/grading/student_form_screen.dart';
import 'screens/grading/student_profile_screen.dart';
import 'screens/grading/attendance_screen.dart';
import 'screens/grading/quiz_screen.dart';
import 'screens/grading/exam_screen.dart';
import 'screens/grading/activity_screen.dart';
import 'screens/grading/oral_recitation_screen.dart';
import 'screens/grading/project_screen.dart';
import 'screens/grading/grade_summary_screen.dart';
import 'screens/grading/class_overview_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeSqflite();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

// ── Router ────────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/todos',
  routes: [
    // ── Shell (bottom nav wraps only the two tab roots) ───────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0 — Todos
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/todos',
              builder: (_, __) => const TodoScreen(),
            ),
          ],
        ),
        // Tab 1 — Grading
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/grading',
              builder: (_, __) => const StudentListScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Todo sub-routes (full screen, no bottom nav) ──────────────────────────
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/todos/new',
      builder: (_, __) => const TodoFormScreen(),
    ),
    GoRoute(
      path: '/todos/edit/:id',
      builder: (context, state) =>
          TodoFormScreen(todoId: state.pathParameters['id']!),
    ),

    // ── Grading sub-routes (full screen, no bottom nav) ───────────────────────
    GoRoute(
      path: '/grading/overview',
      builder: (_, __) => const ClassOverviewScreen(),
    ),
    GoRoute(
      path: '/grading/new-student',
      builder: (_, __) => const StudentFormScreen(),
    ),
    GoRoute(
      path: '/grading/student/:id',
      builder: (context, state) =>
          StudentProfileScreen(studentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/grading/student/:id/edit',
      builder: (context, state) =>
          StudentFormScreen(studentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/grading/student/:id/attendance',
      builder: (context, state) =>
          AttendanceScreen(studentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/grading/student/:id/quizzes',
      builder: (context, state) =>
          QuizScreen(studentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/grading/student/:id/exams',
      builder: (context, state) =>
          ExamScreen(studentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/grading/student/:id/activities',
      builder: (context, state) =>
          ActivityScreen(studentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/grading/student/:id/oral-recitations',
      builder: (context, state) =>
          OralRecitationScreen(studentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/grading/student/:id/projects',
      builder: (context, state) =>
          ProjectScreen(studentId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/grading/student/:id/grade-summary',
      builder: (context, state) =>
          GradeSummaryScreen(studentId: state.pathParameters['id']!),
    ),
  ],
);

// ── App ───────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TeachDesk',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// ── Shell with bottom nav ─────────────────────────────────────────────────────

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.divider, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              activeIcon: Icon(Icons.check_circle),
              label: 'Todos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Grading',
            ),
          ],
        ),
      ),
    );
  }
}
