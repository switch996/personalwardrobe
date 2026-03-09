import 'package:flutter/material.dart';

class DsColors {
  static const Color paper = Color(0xFFFAF6EF);
  static const Color paperDeep = Color(0xFFF2EBDD);
  static const Color ink = Color(0xFF2D261E);
  static const Color mutedInk = Color(0xFF6A6158);
  static const Color line = Color(0xFFDDD1C1);
  static const Color copper = Color(0xFFAD7E45);
  static const Color shadow = Color(0x1A4A3520);
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
        color: const Color(0xCCFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: DsRadius.lg,
          side: const BorderSide(color: DsColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xCCFFFFFF),
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
        selectedColor: const Color(0x35AD7E45),
        side: const BorderSide(color: DsColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(color: DsColors.ink),
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
