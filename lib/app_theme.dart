import 'package:flutter/material.dart';

// Cartridge color palette.
class AppColors {
  static const Color hunterGreen = Color(0xFF386641);
  static const Color sageGreen = Color(0xFF6A994E);
  static const Color yellowGreen = Color(0xFFA7C957);
  static const Color vanillaCream = Color(0xFFF2E8CF);
  static const Color blushedBrick = Color(0xFFBC4749);

  // Status colors for StatusChips and the Stats screen.
  static const Color playing = sageGreen;
  static const Color completed = hunterGreen;
  static const Color dropped = blushedBrick;
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.hunterGreen,
      primary: AppColors.hunterGreen,
      onPrimary: Colors.white,
      secondary: AppColors.sageGreen,
      onSecondary: Colors.white,
      tertiary: AppColors.yellowGreen,
      onTertiary: AppColors.hunterGreen,
      error: AppColors.blushedBrick,
      onError: Colors.white,
      surface: AppColors.vanillaCream,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.vanillaCream,
      appBarTheme: const AppBarThemeData(
        backgroundColor: AppColors.hunterGreen,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.hunterGreen,
        selectedItemColor: AppColors.yellowGreen,
        unselectedItemColor: AppColors.vanillaCream.withValues(alpha: 0.7),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.hunterGreen,
          foregroundColor: Colors.white,
        ),
      ),
      chipTheme: const ChipThemeData(selectedColor: AppColors.yellowGreen),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.hunterGreen,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
