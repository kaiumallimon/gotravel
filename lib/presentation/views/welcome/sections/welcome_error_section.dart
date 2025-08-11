import 'package:flutter/material.dart';
import 'package:gotravel/presentation/providers/welcome_viewmodel.dart';
import 'package:gotravel/presentation/widgets/custom_button.dart';

class WelcomeErrorSection extends StatelessWidget {
  final ThemeData theme;
  final WelcomeProvider welcomeProvider;

  const WelcomeErrorSection({
    super.key,
    required this.theme,
    required this.welcomeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              welcomeProvider.error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Try Again',
              height: 48,
              width: 160,
              onPressed: () => welcomeProvider.loadWelcomeData(),
            ),
          ],
        ),
      ),
    );
  }
}
