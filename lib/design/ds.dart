import 'package:flutter/material.dart';

class DsColors {
  static const Color paper = Color(0xFFFFFFFF);
  static const Color paperDeep = Color(0xFFF3F3F3);
  static const Color ink = Color(0xFF111111);
  static const Color mutedInk = Color(0xFF666666);
  static const Color line = Color(0xFFD9D9D9);
  static const Color red = Color(0xFFD32F2F);
  static const Color redDeep = Color(0xFFB71C1C);
  static const Color redSoft = Color(0xFFFFEBEE);
  static const Color redSoftStrong = Color(0x33D32F2F);
  static const Color copper = red;
  static const Color shadow = Color(0x1A000000);
}

class DsRadius {
  static const BorderRadius md = BorderRadius.all(Radius.circular(14));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(20));
}

class DsSpace {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 24;
}

class Ds {
  static ThemeData themeData() {
    const scheme = ColorScheme.light(
      surface: DsColors.paper,
      onSurface: DsColors.ink,
      primary: DsColors.copper,
      onPrimary: Colors.white,
      secondary: DsColors.paperDeep,
      onSecondary: DsColors.ink,
      outline: DsColors.line,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DsColors.paper,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: DsColors.paper,
        foregroundColor: DsColors.ink,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DsRadius.lg,
          side: const BorderSide(color: DsColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: DsRadius.md,
          borderSide: const BorderSide(color: DsColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DsRadius.md,
          borderSide: const BorderSide(color: DsColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DsRadius.md,
          borderSide: const BorderSide(color: DsColors.copper, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DsColors.paperDeep,
        selectedColor: DsColors.redSoftStrong,
        side: const BorderSide(color: DsColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(color: DsColors.ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DsColors.paper,
        indicatorColor: DsColors.redSoft,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: DsColors.red);
          }
          return const IconThemeData(color: DsColors.mutedInk);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: DsColors.red, fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: DsColors.mutedInk);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DsColors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: DsRadius.md),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DsColors.red,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: DsColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: DsColors.ink,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: DsColors.ink, height: 1.3),
        bodySmall: TextStyle(fontSize: 12, color: DsColors.mutedInk),
      ),
    );
  }
}
