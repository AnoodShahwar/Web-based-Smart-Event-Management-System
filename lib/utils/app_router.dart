import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Placeholder screens for now
import '../screens/auth.dart';
import '../screens/student.dart';
import '../screens/admin.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const AuthScreen()),
    GoRoute(
      path: '/student',
      builder: (context, state) => const StudentScreen(),
    ),
    GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
  ],
);
