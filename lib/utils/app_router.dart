import 'package:go_router/go_router.dart';
import '../screens/auth.dart';
import '../screens/student.dart';
import '../screens/admin.dart';
import '../screens/event_details.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const AuthScreen()),
    GoRoute(
      path: '/student',
      builder: (context, state) => const StudentScreen(),
    ),
    GoRoute(path: '/admin', builder: (context, state) => const AdminScreen()),
    GoRoute(
      path: '/event/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EventDetailScreen(eventId: id);
      },
    ),
  ],
);
