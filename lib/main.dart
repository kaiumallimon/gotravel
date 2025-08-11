import 'package:flutter/material.dart';
import 'package:gotravel/core/routes/app_router.dart';
import 'package:gotravel/presentation/providers/welcome_viewmodel.dart';
import 'package:gotravel/theming/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WelcomeProvider()),
      ],
      child: MaterialApp.router(
        title: 'GoTravel',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerDelegate: AppRouter.router.routerDelegate,
        routeInformationParser: AppRouter.router.routeInformationParser,
        routeInformationProvider: AppRouter.router.routeInformationProvider,
      ),
    );
  }
}
