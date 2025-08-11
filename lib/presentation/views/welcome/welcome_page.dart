import 'package:flutter/material.dart';
import 'package:gotravel/presentation/providers/welcome_viewmodel.dart';
import 'package:gotravel/presentation/views/welcome/sections/sections.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WelcomeProvider>(context, listen: false).loadWelcomeData();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<WelcomeProvider>(
        builder: (context, welcomeProvider, child) {
          if (welcomeProvider.isLoading) {
            return WelcomeLoadingSection(theme: theme);
          }

          if (welcomeProvider.error != null) {
            return WelcomeErrorSection(
              theme: theme,
              welcomeProvider: welcomeProvider,
            );
          }

          if (welcomeProvider.welcomeData == null ||
              welcomeProvider.welcomeData!.isEmpty) {
            return const Center(child: Text('No welcome data available'));
          }

          return Column(
            children: [
              // Main content area - full screen with overlay header
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: welcomeProvider.welcomeData!.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final data = welcomeProvider.welcomeData![index];
                    return WelcomeCardSection(
                      data: data,
                      size: size,
                      theme: theme,
                      animationController: _animationController,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                    );
                  },
                ),
              ),

              // Bottom section with indicators and buttons
              WelcomeBottomSection(
                theme: theme,
                welcomeProvider: welcomeProvider,
                currentIndex: _currentIndex,
                pageController: _pageController,
              ),
            ],
          );
        },
      ),
    );
  }
}
