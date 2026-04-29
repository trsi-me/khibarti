import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ألوان احترافية — بدون أبيض للخطوط (كريمي/عاجي على الخلفيات الداكنة)
class AppColors {
  static const Color primary = Color(0xFF1B5E57);
  static const Color primaryDark = Color(0xFF0D3D38);
  static const Color accent = Color(0xFF2E7D6E);
  static const Color darkBlue = Color(0xFF1565C0);
  static const Color cardBg = Color(0xFFF8FAF9);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF555555);
  /// بديل للأبيض — كريمي/عاجي واضح على الخلفيات الداكنة
  static const Color onPrimary = Color(0xFFFFFBF0);
  static const Color surface = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData lightTheme({bool accessibilityMode = false}) {
    final scale = accessibilityMode ? 1.2 : 1.0;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 20 * scale,
          fontWeight: FontWeight.bold,
          color: AppColors.onPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
      ),
      // TabBar داخل AppBar على خلفية primary — بدون هذا يظهر نص التبويبات بلون منخفض التباين
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xC7FFFFFF),
        indicatorColor: Colors.white,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 12 * scale,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.4),
          padding: EdgeInsets.symmetric(
            horizontal: 20 * scale,
            vertical: 12 * scale,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 16 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 12 * scale),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: const BorderSide(color: AppColors.primary),
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 16 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 15 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 20 * scale,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 16 * scale,
          color: AppColors.textPrimary,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(
        TextTheme(
          bodyLarge: TextStyle(
            fontSize: (17 * scale).clamp(15.0, 24.0),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            fontSize: (15 * scale).clamp(13.0, 20.0),
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          titleLarge: TextStyle(
            fontSize: (22 * scale).clamp(20.0, 30.0),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: (19 * scale).clamp(17.0, 26.0),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          labelLarge: TextStyle(
            fontSize: (16 * scale).clamp(14.0, 22.0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
