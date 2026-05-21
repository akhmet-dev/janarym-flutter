import 'package:flutter/material.dart';

/// Centralized design system — colors, typography, and UI constants.
class AppTheme {
  AppTheme._();

  // ─── Colors ───
  static const Color background = Color(0xFF0A0A14);
  static const Color surface = Color(0xFF121220);
  static const Color surfaceLight = Color(0xFF1A1A2E);
  static const Color cardBg = Color(0xFF16162A);

  static const Color primary = Color(0xFF33C759);
  static const Color primaryDark = Color(0xFF28A745);
  static const Color primaryLight = Color(0xFF5CD77E);

  static const Color accent = Color(0xFF00BCD4);
  static const Color accentLight = Color(0xFF4DD0E1);

  static const Color recording = Color(0xFFFB7233);
  static const Color processing = Color(0xFF8C5CF5);
  static const Color speaking = Color(0xFF33C78D);
  static const Color error = Color(0xFFF24444);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 0.7
  static const Color textTertiary = Color(0x80FFFFFF); // 0.5
  static const Color textDisabled = Color(0x4DFFFFFF); // 0.3

  static const Color divider = Color(0x1AFFFFFF); // 0.1
  static const Color overlay = Color(0x8C000000); // 0.55
  static const Color overlayLight = Color(0x26FFFFFF); // 0.15

  static const Color premium = Color(0xFF33C759);
  static const Color vip = Color(0xFFFFD700);

  // ─── Gradients ───
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A14), Color(0xFF121928)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF33C759), Color(0xFF28A745)],
  );

  // ─── Typography ───
  static const String fontFamily = 'Inter';

  static TextStyle heading1 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle heading2 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle heading3 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle body = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static TextStyle bodySmall = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static TextStyle caption = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textTertiary,
  );

  static TextStyle label = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );

  static TextStyle button = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  // ─── Border Radius ───
  static const double radiusSmall = 8;
  static const double radiusMedium = 14;
  static const double radiusLarge = 22;
  static const double radiusXLarge = 32;

  // ─── Spacing ───
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;

  // ─── ThemeData ───
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        fontFamily: fontFamily,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: surface,
          error: error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: heading3,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.black,
            textStyle: button,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMedium),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: overlayLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            borderSide: const BorderSide(color: primary),
          ),
        ),
      );
}
