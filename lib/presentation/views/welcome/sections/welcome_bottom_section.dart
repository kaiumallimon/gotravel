import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotravel/core/routes/app_routes.dart';
import 'package:gotravel/presentation/providers/welcome_viewmodel.dart';
import 'package:gotravel/presentation/widgets/custom_button.dart';

class WelcomeBottomSection extends StatelessWidget {
  final ThemeData theme;
  final WelcomeProvider welcomeProvider;
  final int currentIndex;
  final PageController pageController;

  const WelcomeBottomSection({
    super.key,
    required this.theme,
    required this.welcomeProvider,
    required this.currentIndex,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              welcomeProvider.welcomeData!.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: currentIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? theme.colorScheme.primary
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              // Previous/Back button (if not first page)
              if (currentIndex > 0)
                Expanded(
                  child: CustomButton(
                    text: 'Back',
                    isOutlined: true,
                    height: 56,
                    onPressed: () {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),

              if (currentIndex > 0) const SizedBox(width: 16),

              // Next/Get Started button
              Expanded(
                flex: currentIndex > 0 ? 1 : 1,
                child: CustomButton(
                  text: currentIndex == welcomeProvider.welcomeData!.length - 1
                      ? 'Get Started'
                      : 'Next',
                  height: 56,
                  onPressed: () {
                    if (currentIndex ==
                        welcomeProvider.welcomeData!.length - 1) {
                      context.go(AppRoutes.login);
                    } else {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ],
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
