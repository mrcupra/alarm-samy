import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SamyColors {
  // Primary Royal & Electric Blues
  static const Color primaryBlue = Color(0xFF0057FF);
  static const Color royalBlue = Color(0xFF1A6BFF);
  static const Color electricCyan = Color(0xFF00D2FF);
  static const Color deepCobalt = Color(0xFF0038B8);
  static const Color softSky = Color(0xFFEAF3FF);

  // Light Mode Palette (أزرق في أبيض فخم)
  static const Color lightBg = Color(0xFFF3F8FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFD6E6FF);
  static const Color lightTextPrimary = Color(0xFF071A3E);
  static const Color lightTextSecondary = Color(0xFF4E6793);

  // Dark Mode Palette (دارك مود أزرق ملكي)
  static const Color darkBg = Color(0xFF050C1D);
  static const Color darkBgSecondary = Color(0xFF091530);
  static const Color darkSurface = Color(0xFF0F2044);
  static const Color darkSurfaceElevated = Color(0xFF152B59);
  static const Color darkCardBorder = Color(0xFF214285);
  static const Color darkTextPrimary = Color(0xFFF4F8FF);
  static const Color darkTextSecondary = Color(0xFF8BA9D9);

  // Status & Pro Accents
  static const Color proGold = Color(0xFFFFB800);
  static const Color proCyan = Color(0xFF00E5FF);
  static const Color successGreen = Color(0xFF00C875);
  static const Color warningAmber = Color(0xFFFF9F1C);
  static const Color dangerRed = Color(0xFFFF3B5C);

  static LinearGradient primaryGradient(bool isDark) => LinearGradient(
        colors: isDark
            ? const [Color(0xFF0057FF), Color(0xFF00B4FF)]
            : const [Color(0xFF0047E0), Color(0xFF2684FF)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );

  static LinearGradient proGradient() => const LinearGradient(
        colors: [Color(0xFF0040C1), Color(0xFF0077FF), Color(0xFF00D4FF)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );

  static LinearGradient backgroundGradient(bool isDark) => LinearGradient(
        colors: isDark
            ? const [Color(0xFF040A18), Color(0xFF091736), Color(0xFF050C1D)]
            : const [Color(0xFFEBF4FF), Color(0xFFF7FAFF), Color(0xFFFFFFFF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}

class SamyTheme {
  static ThemeData buildTheme(bool isDark) {
    final baseTextTheme =
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    final cairoTextTheme = GoogleFonts.cairoTextTheme(baseTextTheme).apply(
      bodyColor: isDark ? SamyColors.darkTextPrimary : SamyColors.lightTextPrimary,
      displayColor:
          isDark ? SamyColors.darkTextPrimary : SamyColors.lightTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor:
          isDark ? SamyColors.darkBg : SamyColors.lightBg,
      primaryColor: SamyColors.primaryBlue,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: isDark ? SamyColors.electricCyan : SamyColors.primaryBlue,
        onPrimary: Colors.white,
        secondary: SamyColors.royalBlue,
        onSecondary: Colors.white,
        error: SamyColors.dangerRed,
        onError: Colors.white,
        surface: isDark ? SamyColors.darkSurface : SamyColors.lightSurface,
        onSurface:
            isDark ? SamyColors.darkTextPrimary : SamyColors.lightTextPrimary,
      ),
      textTheme: cairoTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: cairoTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 21,
          color:
              isDark ? SamyColors.darkTextPrimary : SamyColors.lightTextPrimary,
        ),
      ),
    );
  }
}
