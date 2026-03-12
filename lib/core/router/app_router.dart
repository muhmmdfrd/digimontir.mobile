import 'package:go_router/go_router.dart';
import '../../modules/splash/screen/splash_screen.dart';
import '../../modules/login/screen/login_screen.dart';
import '../../modules/main/screen/main_shell.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: main,
        name: 'main',
        builder: (context, state) => const MainShell(),
      ),
    ],
  );
}

