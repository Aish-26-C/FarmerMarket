import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary =
      Color(0xFF2E7D32);

  static const Color secondary =
      Color(0xFFFFA000);

  static const Color background =
      Color(0xFFF7F8F3);

  static const Color dark =
      Color(0xFF18321B);

  static ThemeData lightTheme =
      ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor:
        background,

    colorScheme:
        ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),

    fontFamily: 'Roboto',

    appBarTheme:
        const AppBarTheme(
      backgroundColor:
          background,
      foregroundColor: dark,
      elevation: 0,
      centerTitle: false,
    ),

    inputDecorationTheme:
        InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            BorderSide.none,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            BorderSide.none,
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            const BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
    ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor:
            Colors.white,
        minimumSize:
            const Size(
          double.infinity,
          54,
        ),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),
    ),
  );
}