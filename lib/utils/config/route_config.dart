import 'package:go_router/go_router.dart';
import 'package:shaheen_namaz/screens/auth/login_screen.dart';

final routes = GoRouter(
  initialLocation: "/login",
  routes: [
    GoRoute(
      path: "/login",
      builder: (ctx, state) => const LoginScreen(),
    )
  ],
);
