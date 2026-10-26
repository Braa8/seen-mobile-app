import 'package:flutter/material.dart';

abstract final class SeenColors {
  static const paper = Color(0xFFF5F1E8);
  static const card = Color(0xFFFFFCF6);
  static const ink = Color(0xFF192A2A);
  static const muted = Color(0xFF687573);
  static const teal = Color(0xFF1D5B57);
  static const tealDark = Color(0xFF123D3A);
  static const gold = Color(0xFFC49A50);
  static const line = Color(0xFFE3DED2);
  static const darkBackground = Color(0xFF111B1B);
  static const darkCard = Color(0xFF1B2928);
}

abstract final class SeenTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: SeenColors.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: SeenColors.teal,
      brightness: Brightness.light,
      primary: SeenColors.teal,
      secondary: SeenColors.gold,
      surface: SeenColors.card,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: SeenColors.paper,
      foregroundColor: SeenColors.ink,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: SeenColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: SeenColors.line),
      ),
    ),
    dividerColor: SeenColors.line,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SeenColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: SeenColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: SeenColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: SeenColors.teal, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: SeenColors.card,
      indicatorColor: SeenColors.teal.withValues(alpha: .12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) =>
        TextStyle(fontSize: 11, fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500)),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 30, height: 1.25, fontWeight: FontWeight.w800, color: SeenColors.ink),
      headlineMedium: TextStyle(fontSize: 24, height: 1.3, fontWeight: FontWeight.w800, color: SeenColors.ink),
      titleLarge: TextStyle(fontSize: 19, height: 1.35, fontWeight: FontWeight.w800, color: SeenColors.ink),
      titleMedium: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w700, color: SeenColors.ink),
      bodyLarge: TextStyle(fontSize: 16, height: 1.75, color: SeenColors.ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.6, color: SeenColors.ink),
      bodySmall: TextStyle(fontSize: 12, height: 1.5, color: SeenColors.muted),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SeenColors.darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: SeenColors.teal,
      brightness: Brightness.dark,
      primary: const Color(0xFF72B8AE),
      secondary: SeenColors.gold,
      surface: SeenColors.darkCard,
    ),
    cardTheme: CardThemeData(
      color: SeenColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
  );
}
