import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/routes/app_routes.dart';
import 'package:gotravel/presentation/views/admin/admin_wrapper.dart';
import 'package:gotravel/presentation/views/splash/splash_page.dart';
import 'package:gotravel/presentation/views/user/user_wrapper.dart';
import 'package:gotravel/presentation/views/welcome/welcome_page.dart';

import 'package:gotravel/presentation/views/auth/sign_in_page.dart';
import 'package:gotravel/presentation/views/auth/sign_up_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      /// Splash route with custom slide transition
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SplashPage(),
            transitionsBuilder: _slideTransition,
          );
        },
      ),

      /// Welcome route with custom slide transition
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const WelcomePage(),
            transitionsBuilder: _slideTransition,
          );
        },
      ),

      /// Sign In route
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SignInPage(),
            transitionsBuilder: _slideTransition,
          );
        },
      ),

      /// Sign Up route
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SignUpPage(),
            transitionsBuilder: _slideTransition,
          );
        },
      ),

      /// Home route
      GoRoute(
        path: AppRoutes.userWrapper,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const UserWrapper(),
            transitionsBuilder: _slideTransition,
          );
        },
      ),

      /// Admin route
      GoRoute(
        path: AppRoutes.adminWrapper,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AdminWrapper(),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
    ],
  );

  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: true,
      child: child,
    );
  }
}
