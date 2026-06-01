import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF1A1D27);
  static const Color surfaceElevated = Color(0xFF222535);
  static const Color accent = Color(0xFF4ECDC4);
  static const Color accentDim = Color(0xFF2A7A75);
  static const Color textPrimary = Color(0xFFF0F2F8);
  static const Color textSecondary = Color(0xFF8B8FA8);
  static const Color textMuted = Color(0xFF4A4D60);
  static const Color divider = Color(0xFF252838);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFB347);
  static const Color success = Color(0xFF6BCB77);

  // Priority colors
  static const Color priorityLow = Color(0xFF6BCB77);
  static const Color priorityMedium = Color(0xFFFFB347);
  static const Color priorityHigh = Color(0xFFFF6B6B);

  // Section colors
  static const Color sectionA = Color(0xFF4ECDC4);
  static const Color sectionB = Color(0xFFFF9F43);

  // Grade colors
  static const Color gradeExcellent = Color(0xFF6BCB77);
  static const Color gradeGood = Color(0xFF4ECDC4);
  static const Color gradePassing = Color(0xFFFFB347);
  static const Color gradeFailing = Color(0xFFFF6B6B);

  // ── Typography ────────────────────────────────────────────────────────────
  static const String fontFamily = 'GeneralSans'; // fallback: sans-serif

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        background: background,
        surface: surface,
        primary: accent,
        secondary: accentDim,
        error: error,
        onBackground: textPrimary,
        onSurface: textPrimary,
        onPrimary: background,
      ),
      fontFamily: fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: background,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: accentDim,
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontFamily: fontFamily,
        ),
        side: const BorderSide(color: divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: background,
        elevation: 4,
        shape: CircleBorder(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontFamily: fontFamily,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ── Text Styles ───────────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.8,
    height: 1.1,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.1,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textMuted,
    letterSpacing: 0.6,
  );

  // ── Grade color helper ────────────────────────────────────────────────────
  static Color gradeColor(double grade) {
    if (grade >= 90) return gradeExcellent;
    if (grade >= 80) return gradeGood;
    if (grade >= 75) return gradePassing;
    return gradeFailing;
  }
}
