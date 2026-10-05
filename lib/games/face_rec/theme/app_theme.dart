import 'package:flutter/material.dart';

class AppTheme {
  // EVANAMI Serene Hearth Color Palette
  static const Color colorBackground = Color(0xFFF5EFE8);       // Warm Cream Background
  static const Color colorSurface = Color(0xFFF3EDE6);          // Soft Beige Surface
  static const Color colorSurfaceLow = Color(0xFFF9F3EC);       // Container Low Cream
  static const Color colorCardBg = Color(0xFFFFFFFF);           // Crisp White Card
  
  static const Color colorPrimary = Color(0xFF2F4860);          // Deep Navy (Primary Anchor)
  static const Color colorSecondary = Color(0xFF35618F);        // Secondary Navy/Blue
  static const Color colorSecondaryAction = Color(0xFF35618F);  // Secondary Action Blue
  static const Color colorSoftBlue = Color(0xFF7DA7D9);         // Soft Cobalt / Sky Blue
  static const Color colorSecondaryFixed = Color(0xFFD1E4FF);   // Secondary Fixed Light Blue
  static const Color colorSelectedBg = Color(0xFFE8F0F8);       // Selected Choice Light Blue Tint
  
  static const Color colorAccentWarm = Color(0xFF2F4860);       // Warm Navy Accent
  static const Color colorButterYellow = Color(0xFFFFF1C7);     // Morning Highlight Yellow
  static const Color colorBorderGray = Color(0xFFD8DEE6);       // Light Border Gray
  static const Color colorOutlineVariant = Color(0xFFC3C7CD);
  
  static const Color colorTextPrimary = Color(0xFF2F4860);     // WCAG AAA Deep Navy Text
  static const Color colorTextSecondary = Color(0xFF43474D);   // Secondary Slate Text
  static const Color colorHintBg = Color(0xFFF9F3EC);
  
  static const Color colorSuccess = Color(0xFF357A38);          // Gentle Affirming Green
  static const Color colorSuccessBg = Color(0xFFEEF7EE);        // Gentle Success Light Tint
  static const Color colorError = Color(0xFFBA1A1A);            // Gentle Error Red
  static const Color colorErrorContainer = Color(0xFFFFDAD6);   // Error Red Light Tint

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colorBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: colorPrimary,
        onPrimary: Colors.white,
        secondary: colorSecondary,
        onSecondary: Colors.white,
        error: colorError,
        onError: Colors.white,
        surface: colorSurface,
        onSurface: colorTextPrimary,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: colorTextPrimary,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colorTextPrimary,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorTextPrimary,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colorTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: colorTextPrimary,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: colorTextSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colorTextPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 58), // >48dp touch target
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999), // Pill Shape
          ),
          backgroundColor: colorPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorCardBg,
        elevation: 1,
        shadowColor: colorPrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: colorBorderGray, width: 1.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: colorBackground,
        foregroundColor: colorTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorTextPrimary,
        ),
      ),
    );
  }
}
