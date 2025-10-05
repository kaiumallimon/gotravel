import 'package:flutter/material.dart';
import 'package:gotravel/core/routes/app_router.dart';
import 'package:gotravel/presentation/providers/admin_hotels_provider.dart';
import 'package:gotravel/presentation/providers/admin_packages_provider.dart';
import 'package:gotravel/presentation/providers/admin_wrapper_provider.dart';
import 'package:gotravel/presentation/providers/welcome_viewmodel.dart';
import 'package:gotravel/presentation/providers/sign_in_provider.dart';
import 'package:gotravel/presentation/providers/sign_up_provider.dart';
import 'package:gotravel/presentation/providers/add_hotel_provider.dart';
import 'package:gotravel/presentation/providers/add_package_provider.dart';
import 'package:gotravel/theming/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  /// Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('welcome');
  await Hive.openBox('user');

  /// Load environment variables
  await dotenv.load(fileName: ".env");

  /// Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANONKEY']!,
  );

  /// Run the app
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

        /// Admin-wrapper-provider
        ChangeNotifierProvider(create: (context) => AdminWrapperProvider()),

        /// Add Hotel Provider
        ChangeNotifierProvider(create: (context) => AddHotelProvider()),

        // Admin Hotels Provider
        ChangeNotifierProvider(create: (context) => AdminHotelsProvider()),

        /// Add Package Provider
        ChangeNotifierProvider(create: (context) => AddPackageProvider()),

        /// Admin Packages Provider
        ChangeNotifierProvider(create: (context) => AdminPackagesProvider()),
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
