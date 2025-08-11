import 'package:go_router/go_router.dart';
import 'package:gotravel/core/routes/app_routes.dart';
import 'package:gotravel/presentation/views/splash/splash_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) {
          return const SplashPage();
        },
      ),
    ],
  );
}
