import 'package:go_router/go_router.dart';
import 'package:main_app/HomePageAll/HomePage.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  debugLogDiagnostics: true, 
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
