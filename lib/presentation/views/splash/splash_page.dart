import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/constants/app_assets.dart';
import 'package:gotravel/core/routes/app_routes.dart';
import 'package:gotravel/data/services/local/hive_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  /// Animation controller for the splash screen animations
  /// Controls the fade and scale animations
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  /// Initializes the animation controller and animations
  /// This method is called when the widget is inserted into the widget tree.
  @override
  void initState() {
    super.initState();

    /// Create the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    /// Create the fade animation
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    /// Create the scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    /// Start the animations
    _controller.forward();

    /// after 2 seconds, navigate to the welcome page
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        navigate(context);
      }
    });
  }

  /// Disposes the animation controller
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigate(BuildContext context) {
    // Retrieve value from Hive
    final hasSeen = HiveService.getData(
      'welcome',
      'hasSeen',
      defaultValue: false,
    );

    /*HiveService.openBox('user');
      HiveService.saveData('user', 'accountData', response);
      context.push(AppRoutes.home);*/

    final userData = HiveService.getData(
      'user',
      'accountData',
      defaultValue: null,
    );

    // Check if user data exists
    if (userData != null && userData['id'] != null) {
      // Navigate to home if user data exists
      context.go(AppRoutes.home);
      return;
    } else {
      if (hasSeen == true) {
        // Navigate to login if already seen welcome
        context.go(AppRoutes.login);
      } else {
        // Navigate to welcome screen if not seen
        context.go(AppRoutes.welcome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Get the size of the screen
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background map
          Positioned.fill(
            child: SvgPicture.asset(AppAssets.worldMap, fit: BoxFit.cover),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Center logo with animation
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAssets.logo,
                      width: size.width * 0.3,
                      height: size.width * 0.3,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "GoTravel",
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading indicator
          Positioned(
            bottom: size.height * 0.1,
            left: 0,
            right: 0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: const CupertinoActivityIndicator(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
