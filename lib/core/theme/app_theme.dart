import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData light(Color primary) {
    final base = ThemeData.light(useMaterial3: false);
    return base.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: AppColors.lightTextMain,
        displayColor: AppColors.lightTextMain,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: AppColors.accent,
      ),
      cardTheme: CardTheme(
        color: Colors.white.withOpacity(0.9),
        elevation: 6,
        shadowColor: primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextMain,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.lightTextMain,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: AppColors.lightTextSecondary,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData dark(Color primary) {
    final base = ThemeData.dark(useMaterial3: false);
    return base.copyWith(
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFF0F7F0),
        displayColor: const Color(0xFFF0F7F0),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E2A1D).withOpacity(0.9),
        elevation: 6,
        shadowColor: primary.withOpacity(0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: Colors.white54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      colorScheme: base.colorScheme.copyWith(primary: primary, secondary: AppColors.accent),
    );
  }
}
