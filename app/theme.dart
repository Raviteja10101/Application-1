import 'package:flutter/material.dart';

class KnotHabitsTheme {
  static const Color primaryGreen = Color(0xFF00865A);
  static const Color background = Color(0xFFF7F7FD);
  static const Color cardColor = Colors.white;
  static const Color lightPurple = Color(0xFFE9EBFF);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
      ),

      fontFamily: 'sans',

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: lightPurple,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontWeight: FontWeight.w700,
                color: primaryGreen,
              );
            }

            return const TextStyle(
              fontWeight: FontWeight.w600,
              color: textPrimary,
            );
          },
        ),
      ),
    );
  }
}