import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/routes/app_routes.dart';
import 'package:gotravel/data/models/hotel_model.dart';
import 'package:gotravel/data/models/tour_package_model.dart';
import 'package:gotravel/presentation/views/admin/admin_wrapper.dart';
import 'package:gotravel/presentation/views/admin/hotels/pages/add_hotel_page.dart';
import 'package:gotravel/presentation/views/admin/hotels/pages/detailed_hotel_page.dart';
import 'package:gotravel/presentation/views/admin/packages/pages/add_package_page.dart';
import 'package:gotravel/presentation/views/admin/packages/pages/detailed_package_page.dart';
import 'package:gotravel/presentation/views/admin/recommendations/pages/admin_recommendations_page.dart';
import 'package:gotravel/presentation/views/splash/splash_page.dart';
import 'package:gotravel/presentation/views/user/user_wrapper.dart';
import 'package:gotravel/presentation/views/user/pages/package_details_page.dart';
import 'package:gotravel/presentation/views/user/pages/user_packages_page.dart';
import 'package:gotravel/presentation/views/user/pages/booking_page.dart';
import 'package:gotravel/presentation/views/user/pages/payment_success_page.dart';
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
        routes: [
          /// Add Hotel route
          GoRoute(
            path: AppRoutes.addHotel,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AdminAddHotelPage(),
                transitionsBuilder: _slideTransition,
              );
            },
          ),

          GoRoute(
            path: AppRoutes.detailedHotel,
            pageBuilder: (context, state) {
              final data = state.extra as Map<String, dynamic>?;
              final hotel = Hotel.fromMap(data!);

              return CustomTransitionPage(
                key: state.pageKey,
                child: DetailedHotelPage(
                  hotel: hotel,
                ),
                transitionsBuilder: _slideTransition,
              );
            },
          ),

          /// Add Package route
          GoRoute(
            path: AppRoutes.addPackage,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AdminAddPackagePage(),
                transitionsBuilder: _slideTransition,
              );
            },
          ),

          GoRoute(
            path: AppRoutes.detailedPackage,
            pageBuilder: (context, state) {
              final package = state.extra as TourPackage;

              return CustomTransitionPage(
                key: state.pageKey,
                child: DetailedPackagePage(
                  package: package,
                ),
                transitionsBuilder: _slideTransition,
              );
            },
          ),

          /// Recommendations route
          GoRoute(
            path: AppRoutes.recommendations,
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: const AdminRecommendationsPage(),
                transitionsBuilder: _slideTransition,
              );
            },
          ),
        ],
      ),
      
      /// Packages route
      GoRoute(
        path: '/packages',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const UserPackagesPage(),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      
      /// Package details route
      GoRoute(
        path: '/package-details/:id',
        pageBuilder: (context, state) {
          final packageId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: PackageDetailsPage(packageId: packageId),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      
      /// Booking route
      GoRoute(
        path: '/booking/:id',
        pageBuilder: (context, state) {
          final packageId = state.pathParameters['id']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: BookingPage(packageId: packageId),
            transitionsBuilder: _slideTransition,
          );
        },
      ),
      
      /// Payment success route
      GoRoute(
        path: '/payment-success',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const PaymentSuccessPage(),
            transitionsBuilder: _slideTransition,
          );
        },
      ),

      /// Add Hotel route
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
