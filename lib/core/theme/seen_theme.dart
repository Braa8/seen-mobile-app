
import 'package:flutter/material.dart';

abstract final class SeenColors {
  // Light editorial palette
  static const paper = Color(0xFFF4F1E8);
  static const card = Color(0xFFFFFDF8);
  static const ink = Color(0xFF26343A);
  static const muted = Color(0xFF707B7D);

  // Seen identity
  static const blue = Color(0xFF244C70);
  static const blueDark = Color(0xFF193852);
  static const blueLight = Color(0xFFE6EDF3);

  // Olive accents
  static const olive = Color(0xFF737A4C);
  static const oliveDark = Color(0xFF59613A);
  static const oliveLight = Color(0xFFEEF0E5);

  // Compatibility with existing screens
  static const teal = blue;
  static const tealDark = blueDark;
  static const gold = olive;

  // Light borders and separators
  static const line = Color(0xFFE4E0D6);

  // Dark editorial palette
  static const darkBackground = Color(0xFF171F26);
  static const darkCard = Color(0xFF222D36);
  static const darkCardElevated = Color(0xFF2B3944);
  static const darkInk = Color(0xFFE9EDF0);
  static const darkMuted = Color(0xFFABB7BE);
  static const darkLine = Color(0xFF394751);

  static const darkBlue = Color(0xFF9BBBD5);
  static const darkOlive = Color(0xFFB5BD8A);
}

abstract final class SeenTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: SeenColors.blue,
      onPrimary: Colors.white,
      primaryContainer: SeenColors.blueLight,
      onPrimaryContainer: SeenColors.blueDark,
      secondary: SeenColors.olive,
      onSecondary: Colors.white,
      secondaryContainer: SeenColors.oliveLight,
      onSecondaryContainer: SeenColors.oliveDark,
      tertiary: Color(0xFF8B6749),
      onTertiary: Colors.white,
      error: Color(0xFFB64242),
      onError: Colors.white,
      errorContainer: Color(0xFFF9E5E2),
      onErrorContainer: Color(0xFF762B2B),
      surface: SeenColors.card,
      onSurface: SeenColors.ink,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFFAF8F2),
      surfaceContainer: Color(0xFFF0EDE4),
      surfaceContainerHigh: Color(0xFFEAE6DC),
      surfaceContainerHighest: Color(0xFFE2DED3),
      outline: SeenColors.line,
      outlineVariant: Color(0xFFD8D4CA),
      shadow: Color(0x1A26343A),
      scrim: Color(0x66000000),
      inverseSurface: SeenColors.ink,
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFFB7D0E3),
      surfaceTint: SeenColors.blue,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: SeenColors.paper,
      dividerColor: SeenColors.line,
      splashColor: SeenColors.blue.withValues(alpha: 0.06),
      highlightColor: SeenColors.blue.withValues(alpha: 0.04),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: SeenColors.paper,
        foregroundColor: SeenColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: SeenColors.ink,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),

      cardTheme: CardThemeData(
        color: SeenColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: SeenColors.line),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SeenColors.card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: SeenColors.blueLight,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? SeenColors.blue : SeenColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 23,
            color: selected ? SeenColors.blue : SeenColors.muted,
          );
        }),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAF8F2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(
          color: SeenColors.muted,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: SeenColors.muted,
          fontSize: 14,
        ),
        prefixIconColor: SeenColors.muted,
        suffixIconColor: SeenColors.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: SeenColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: SeenColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: SeenColors.blue,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFB64242)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFB64242),
            width: 1.6,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SeenColors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: SeenColors.blue.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SeenColors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: SeenColors.blue.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SeenColors.blue,
          side: const BorderSide(color: SeenColors.line),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SeenColors.blue,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: SeenColors.card,
        selectedColor: SeenColors.blueLight,
        disabledColor: SeenColors.line,
        side: const BorderSide(color: SeenColors.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: const TextStyle(
          color: SeenColors.ink,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: SeenColors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: SeenColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SeenColors.card,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: SeenColors.card,
        showDragHandle: true,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: SeenColors.ink,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      iconTheme: const IconThemeData(
        color: SeenColors.blue,
        size: 22,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          height: 1.25,
          fontWeight: FontWeight.w800,
          color: SeenColors.ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          height: 1.3,
          fontWeight: FontWeight.w800,
          color: SeenColors.ink,
        ),
        headlineSmall: TextStyle(
          fontSize: 21,
          height: 1.35,
          fontWeight: FontWeight.w800,
          color: SeenColors.ink,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          height: 1.4,
          fontWeight: FontWeight.w800,
          color: SeenColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w700,
          color: SeenColors.ink,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: SeenColors.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.75,
          color: SeenColors.ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.65,
          color: SeenColors.ink,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.5,
          color: SeenColors.muted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: SeenColors.blue,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: SeenColors.muted,
        ),
      ),
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: SeenColors.darkBlue,
      onPrimary: Color(0xFF14232E),
      primaryContainer: Color(0xFF30495C),
      onPrimaryContainer: Color.fromARGB(255, 205, 224, 237),
      secondary: SeenColors.darkOlive,
      onSecondary: Color(0xFF252B1C),
      secondaryContainer: Color(0xFF414A32),
      onSecondaryContainer: Color(0xFFE5EACF),
      tertiary: Color(0xFFD4AD86),
      onTertiary: Color(0xFF302316),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: SeenColors.darkCard,
      onSurface: Color.fromARGB(255, 109, 137, 159),
      surfaceContainerLowest: Color(0xFF131A20),
      surfaceContainerLow: Color(0xFF1C252D),
      surfaceContainer: SeenColors.darkCard,
      surfaceContainerHigh: SeenColors.darkCardElevated,
      surfaceContainerHighest: Color(0xFF34434E),
      outline: SeenColors.darkLine,
      outlineVariant: Color(0xFF465660),
      shadow: Colors.black,
      scrim: Color(0x99000000),
      inverseSurface: SeenColors.darkInk,
      onInverseSurface: SeenColors.darkBackground,
      inversePrimary: SeenColors.blue,
      surfaceTint: SeenColors.darkBlue,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: SeenColors.darkBackground,
      dividerColor: SeenColors.darkLine,
      splashColor: SeenColors.darkBlue.withValues(alpha: 0.08),
      highlightColor: SeenColors.darkBlue.withValues(alpha: 0.05),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: SeenColors.darkBackground,
        foregroundColor: SeenColors.darkInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: SeenColors.darkInk,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),

      cardTheme: CardThemeData(
        color: SeenColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: SeenColors.darkLine),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SeenColors.darkCard,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFF354B5B),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? SeenColors.darkBlue : SeenColors.darkMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 23,
            color: selected ? SeenColors.darkBlue : SeenColors.darkMuted,
          );
        }),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SeenColors.darkCardElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(
          color: SeenColors.darkMuted,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: SeenColors.darkMuted,
          fontSize: 14,
        ),
        prefixIconColor: SeenColors.darkMuted,
        suffixIconColor: SeenColors.darkMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: SeenColors.darkLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: SeenColors.darkLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: SeenColors.darkBlue,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFF8A80)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFFF8A80),
            width: 1.6,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SeenColors.darkBlue,
          foregroundColor: const Color(0xFF14232E),
          disabledBackgroundColor: SeenColors.darkBlue.withValues(alpha: 0.3),
          disabledForegroundColor: SeenColors.darkMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: SeenColors.darkBlue,
          foregroundColor: const Color(0xFF14232E),
          disabledBackgroundColor: SeenColors.darkBlue.withValues(alpha: 0.3),
          disabledForegroundColor: SeenColors.darkMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SeenColors.darkBlue,
          side: const BorderSide(color: SeenColors.darkLine),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SeenColors.darkBlue,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: SeenColors.darkCard,
        selectedColor: const Color(0xFF354B5B),
        disabledColor: SeenColors.darkCardElevated,
        side: const BorderSide(color: SeenColors.darkLine),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: const TextStyle(
          color: SeenColors.darkInk,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: SeenColors.darkBlue,
          fontWeight: FontWeight.w700,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: SeenColors.darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SeenColors.darkCard,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: SeenColors.darkCard,
        showDragHandle: true,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: SeenColors.darkCardElevated,
        contentTextStyle: const TextStyle(
          color: SeenColors.darkInk,
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      iconTheme: const IconThemeData(
        color: SeenColors.darkBlue,
        size: 22,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          height: 1.25,
          fontWeight: FontWeight.w800,
          color: SeenColors.darkInk,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          height: 1.3,
          fontWeight: FontWeight.w800,
          color: SeenColors.darkInk,
        ),
        headlineSmall: TextStyle(
          fontSize: 21,
          height: 1.35,
          fontWeight: FontWeight.w800,
          color: SeenColors.darkInk,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          height: 1.4,
          fontWeight: FontWeight.w800,
          color: SeenColors.darkInk,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w700,
          color: SeenColors.darkInk,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: SeenColors.darkInk,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.75,
          color: SeenColors.darkInk,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.65,
          color: SeenColors.darkInk,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.5,
          color: SeenColors.darkMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: SeenColors.darkBlue,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: SeenColors.darkMuted,
        ),
      ),
    );
  }
}
