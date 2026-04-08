import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  final Color primary;
  final Color primaryContainer;
  final Color primaryDim;
  final Color primaryFixed;
  final Color primaryFixedDim;
  final Color onPrimary;
  final Color onPrimaryContainer;
  final Color onPrimaryFixed;
  final Color onPrimaryFixedVariant;
  final Color inversePrimary;
  
  final Color secondary;
  final Color secondaryContainer;
  final Color secondaryDim;
  final Color secondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondary;
  final Color onSecondaryContainer;
  final Color onSecondaryFixed;
  final Color onSecondaryFixedVariant;
  
  final Color tertiary;
  final Color tertiaryContainer;
  final Color tertiaryDim;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiary;
  final Color onTertiaryContainer;
  final Color onTertiaryFixed;
  final Color onTertiaryFixedVariant;
  
  final Color background;
  final Color onBackground;
  
  final Color surface;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color surfaceTint;
  
  final Color outline;
  final Color outlineVariant;
  
  final Color error;
  final Color errorContainer;
  final Color errorDim;
  final Color onError;
  final Color onErrorContainer;

  const AppColors({
    required this.primary,
    required this.primaryContainer,
    required this.primaryDim,
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.onPrimaryFixed,
    required this.onPrimaryFixedVariant,
    required this.inversePrimary,
    
    required this.secondary,
    required this.secondaryContainer,
    required this.secondaryDim,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondary,
    required this.onSecondaryContainer,
    required this.onSecondaryFixed,
    required this.onSecondaryFixedVariant,
    
    required this.tertiary,
    required this.tertiaryContainer,
    required this.tertiaryDim,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiary,
    required this.onTertiaryContainer,
    required this.onTertiaryFixed,
    required this.onTertiaryFixedVariant,
    
    required this.background,
    required this.onBackground,
    
    required this.surface,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.surfaceTint,
    
    required this.outline,
    required this.outlineVariant,
    
    required this.error,
    required this.errorContainer,
    required this.errorDim,
    required this.onError,
    required this.onErrorContainer,
  });

  static const darkColors = AppColors(
    primary: Color(0xFFc799ff),
    primaryContainer: Color(0xFFbc87fe),
    primaryDim: Color(0xFFba85fb),
    primaryFixed: Color(0xFFbc87fe),
    primaryFixedDim: Color(0xFFaf7aef),
    onPrimary: Color(0xFF440080),
    onPrimaryContainer: Color(0xFF340064),
    onPrimaryFixed: Color(0xFF000000),
    onPrimaryFixedVariant: Color(0xFF40007a),
    inversePrimary: Color(0xFF7744b5),
    
    secondary: Color(0xFF4af8e3),
    secondaryContainer: Color(0xFF006a60),
    secondaryDim: Color(0xFF33e9d5),
    secondaryFixed: Color(0xFF4af8e3),
    secondaryFixedDim: Color(0xFF33e9d5),
    onSecondary: Color(0xFF005b51),
    onSecondaryContainer: Color(0xFFdcfff8),
    onSecondaryFixed: Color(0xFF00463f),
    onSecondaryFixedVariant: Color(0xFF00655b),
    
    tertiary: Color(0xFFff9dac),
    tertiaryContainer: Color(0xFFfb899c),
    tertiaryDim: Color(0xFFeb7c8f),
    tertiaryFixed: Color(0xFFff8fa2),
    tertiaryFixedDim: Color(0xFFf18194),
    onTertiary: Color(0xFF69162c),
    onTertiaryContainer: Color(0xFF5b0a22),
    onTertiaryFixed: Color(0xFF390010),
    onTertiaryFixedVariant: Color(0xFF6c192e),
    
    background: Color(0xFF0e0e0e),
    onBackground: Color(0xFFffffff),
    
    surface: Color(0xFF0e0e0e),
    surfaceDim: Color(0xFF0e0e0e),
    surfaceBright: Color(0xFF2c2c2c),
    surfaceContainerLowest: Color(0xFF000000),
    surfaceContainerLow: Color(0xFF131313),
    surfaceContainer: Color(0xFF1a1a1a),
    surfaceContainerHigh: Color(0xFF20201f),
    surfaceContainerHighest: Color(0xFF262626),
    onSurface: Color(0xFFffffff),
    onSurfaceVariant: Color(0xFFadaaaa),
    inverseSurface: Color(0xFFfcf9f8),
    inverseOnSurface: Color(0xFF565555),
    surfaceTint: Color(0xFFc799ff),
    
    outline: Color(0xFF767575),
    outlineVariant: Color(0xFF484847),
    
    error: Color(0xFFff6e84),
    errorContainer: Color(0xFFa70138),
    errorDim: Color(0xFFd73357),
    onError: Color(0xFF490013),
    onErrorContainer: Color(0xFFffb2b9),
  );

  static const lightColors = AppColors(
    primary: Color(0xFF7C4DFF),
    primaryContainer: Color(0xFFEADBFF),
    primaryDim: Color(0xFF651FFF),
    primaryFixed: Color(0xFFEADBFF),
    primaryFixedDim: Color(0xFF651FFF),
    onPrimary: Color(0xFFFFFFFF),
    onPrimaryContainer: Color(0xFF24005A),
    onPrimaryFixed: Color(0xFF24005A),
    onPrimaryFixedVariant: Color(0xFF5200D1),
    inversePrimary: Color(0xFFc799ff),
    
    secondary: Color(0xFF00A294),
    secondaryContainer: Color(0xFF7BFDF0),
    secondaryDim: Color(0xFF008376),
    secondaryFixed: Color(0xFF7BFDF0),
    secondaryFixedDim: Color(0xFF00A294),
    onSecondary: Color(0xFFFFFFFF),
    onSecondaryContainer: Color(0xFF00201C),
    onSecondaryFixed: Color(0xFF00201C),
    onSecondaryFixedVariant: Color(0xFF005047),
    
    tertiary: Color(0xFFD21F45),
    tertiaryContainer: Color(0xFFFFD9DF),
    tertiaryDim: Color(0xFFA1002A),
    tertiaryFixed: Color(0xFFFFD9DF),
    tertiaryFixedDim: Color(0xFFD21F45),
    onTertiary: Color(0xFFFFFFFF),
    onTertiaryContainer: Color(0xFF3F000C),
    onTertiaryFixed: Color(0xFF3F000C),
    onTertiaryFixedVariant: Color(0xFF860021),
    
    background: Color(0xFFF9FAFB),
    onBackground: Color(0xFF131313),
    
    surface: Color(0xFFF9FAFB),
    surfaceDim: Color(0xFFE5E7EB),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF3F4F6),
    surfaceContainer: Color(0xFFE5E7EB),
    surfaceContainerHigh: Color(0xFFD1D5DB),
    surfaceContainerHighest: Color(0xFF9CA3AF),
    onSurface: Color(0xFF1A1C1E),
    onSurfaceVariant: Color(0xFF43474E),
    inverseSurface: Color(0xFF2F3033),
    inverseOnSurface: Color(0xFFF1F0F4),
    surfaceTint: Color(0xFF7C4DFF),
    
    outline: Color(0xFF73777F),
    outlineVariant: Color(0xFFC3C7CF),
    
    error: Color(0xFFBA1A1A),
    errorContainer: Color(0xFFFFDAD6),
    errorDim: Color(0xFF93000A),
    onError: Color(0xFFFFFFFF),
    onErrorContainer: Color(0xFF410002),
  );
}

extension ThemeColorsExt on BuildContext {
  AppColors get colors => Theme.of(this).brightness == Brightness.dark 
      ? AppColors.darkColors 
      : AppColors.lightColors;
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25),
        displayMedium: GoogleFonts.manrope(fontSize: 45, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700),
        headlineSmall: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
        titleSmall: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(fontSize: 57, fontWeight: FontWeight.bold, letterSpacing: -0.25, color: AppColors.lightColors.onBackground),
        displayMedium: GoogleFonts.manrope(fontSize: 45, fontWeight: FontWeight.bold, color: AppColors.lightColors.onBackground),
        displaySmall: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.lightColors.onBackground),
        headlineLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.lightColors.onBackground),
        headlineMedium: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.lightColors.onBackground),
        headlineSmall: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.lightColors.onBackground),
        titleLarge: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.lightColors.onBackground),
        titleMedium: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15, color: AppColors.lightColors.onBackground),
        titleSmall: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: AppColors.lightColors.onBackground),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: AppColors.lightColors.onSurface),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: AppColors.lightColors.onSurface),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: AppColors.lightColors.onSurfaceVariant),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: AppColors.lightColors.onSurface),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.lightColors.onSurface),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.lightColors.onSurface),
      ),
    );
  }
}
