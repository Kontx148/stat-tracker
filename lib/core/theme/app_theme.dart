import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xff07090f);
  static const surface = Color(0xff10141d);
  static const surface2 = Color(0xff171c27);
  static const text = Color(0xfff4f7fb);
  static const muted = Color(0xff8c96a8);
  static const accent = Color(0xff6ee7b7);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      surface: surface,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
      titleMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: accent.withValues(alpha: .14),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    useMaterial3: true,
  );
}
