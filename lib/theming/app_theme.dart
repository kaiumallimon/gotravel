import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Define color constants
  static const Color primaryColor = CupertinoColors.activeBlue;
  static const Color backgroundColor = Colors.white;
  static const Color foregroundColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static const Color onSurfaceColor = Colors.black87;

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: foregroundColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        background: backgroundColor,
        onBackground: onSurfaceColor,
      ),

      // Scaffold background
      scaffoldBackgroundColor: backgroundColor,

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Geist',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Geist',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          textStyle: const TextStyle(
            fontFamily: 'Geist',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        titleLarge: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
        titleMedium: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
        titleSmall: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Geist',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: onSurfaceColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Geist',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: onSurfaceColor,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Geist',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: onSurfaceColor,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Geist',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Geist',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Geist',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        hintStyle: TextStyle(fontFamily: 'Geist', color: Colors.grey[500]),
      ),

      // Card theme
      cardTheme: const CardThemeData(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
