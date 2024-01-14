import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/admin/screens/admin_screen.dart';
import 'package:shaheen_namaz/staff/screens/parent_screen.dart';

final routes = GoRouter(
  initialLocation: "/user",
  routes: [
    GoRoute(
      path: "/admin",
      builder: (ctx, state) => const AdminScreen(),
    ),
    GoRoute(
      path: "/user",
      builder: (ctx, state) => const ParentScreen(),
    )
  ],
);
