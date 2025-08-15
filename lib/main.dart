import 'package:flutter/material.dart';
import 'package:gotravel/core/routes/app_router.dart';
import 'package:gotravel/presentation/providers/welcome_viewmodel.dart';
import 'package:gotravel/presentation/providers/sign_in_provider.dart';
import 'package:gotravel/presentation/providers/sign_up_provider.dart';
import 'package:gotravel/theming/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  /// Ensure flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize hive
  await Hive.initFlutter();
  // Open the box
  await Hive.openBox('welcome');

  /// Run the app(root)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// Welcome provider
        ChangeNotifierProvider(create: (context) => WelcomeProvider()),

        /// Sign-In Provider
        ChangeNotifierProvider(create: (context) => SignInProvider()),

        /// Sign-Up Provider
        ChangeNotifierProvider(create: (context) => SignUpProvider()),
      ],
      child: MaterialApp.router(
        title: 'GoTravel',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        /// Routing Configurations
        routerDelegate: AppRouter.router.routerDelegate,
        routeInformationParser: AppRouter.router.routeInformationParser,
        routeInformationProvider: AppRouter.router.routeInformationProvider,
      ),
    );
  }
}
