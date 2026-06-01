import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {

  // ─────────────────────────────────────────────────────
  // DARK THEME  (black background)
  // ─────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg0,
      fontFamily: 'Inter',

      colorScheme: const ColorScheme.dark(
        primary:     AppColors.green,
        secondary:   AppColors.sage,
        surface:     AppColors.darkBg1,
        error:       AppColors.red,
        onPrimary:   AppColors.lightGrey,
        onSurface:   AppColors.darkText1,
        onSecondary: AppColors.darkText1,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor:  AppColors.darkBg0,
        elevation:        0,
        centerTitle:      true,
        titleTextStyle:   AppTextStyles.headingSmall,
        iconTheme:        IconThemeData(color: AppColors.darkText1),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:          Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      cardTheme: CardThemeData(
        color:     AppColors.darkBg1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.darkGlass2,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText3),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.lightGrey,
          elevation:       0,
          minimumSize:     const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.buttonText,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sage,
          textStyle: AppTextStyles.titleSmall,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkText1,
          side: const BorderSide(color: AppColors.darkBorder),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.titleSmall,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     AppColors.darkBg1,
        selectedItemColor:   AppColors.sage,
        unselectedItemColor: AppColors.darkText3,
        elevation:           0,
        type:                BottomNavigationBarType.fixed,
      ),

      dividerTheme: const DividerThemeData(
        color:     AppColors.darkBorder,
        thickness: 1,
        space:     0,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor:  AppColors.darkBg2,
        contentTextStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor:  AppColors.darkBg1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle:   AppTextStyles.headingSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkBg1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkGlass,
        selectedColor:   AppColors.forest,
        labelStyle:      AppTextStyles.labelMedium.copyWith(color: AppColors.darkText1),
        side:            const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      textTheme: TextTheme(
        displayLarge:   AppTextStyles.displayLarge.copyWith(color: AppColors.darkText1),
        displayMedium:  AppTextStyles.displayMedium.copyWith(color: AppColors.darkText1),
        headlineLarge:  AppTextStyles.headingLarge.copyWith(color: AppColors.darkText1),
        headlineMedium: AppTextStyles.headingMedium.copyWith(color: AppColors.darkText1),
        headlineSmall:  AppTextStyles.headingSmall.copyWith(color: AppColors.darkText1),
        titleMedium:    AppTextStyles.titleMedium.copyWith(color: AppColors.darkText1),
        titleSmall:     AppTextStyles.titleSmall.copyWith(color: AppColors.darkText1),
        bodyMedium:     AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText1),
        bodySmall:      AppTextStyles.bodySmall.copyWith(color: AppColors.darkText2),
        labelMedium:    AppTextStyles.labelMedium.copyWith(color: AppColors.darkText2),
        labelSmall:     AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // LIGHT THEME  (light grey background + nature palette)
  // ─────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg0,
      fontFamily: 'Inter',

      colorScheme: const ColorScheme.light(
        primary:     AppColors.darkForest,
        secondary:   AppColors.green,
        surface:     AppColors.lightBg1,
        error:       AppColors.red,
        onPrimary:   Colors.white,
        onSurface:   AppColors.lightText1,
        onSecondary: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor:  AppColors.lightBg0,
        elevation:        0,
        centerTitle:      true,
        titleTextStyle:   TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.lightText1,
        ),
        iconTheme: IconThemeData(color: AppColors.lightText1),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:          Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color:     AppColors.lightBg1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.lightBg2,
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.lightText3,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText2,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkForest, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkForest,
          foregroundColor: Colors.white,
          elevation:       0,
          minimumSize:     const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkForest,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkForest,
          side: const BorderSide(color: AppColors.darkForest),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     AppColors.lightBg1,
        selectedItemColor:   AppColors.darkForest,
        unselectedItemColor: AppColors.lightText3,
        elevation:           0,
        type:                BottomNavigationBarType.fixed,
      ),

      dividerTheme: const DividerThemeData(
        color:     AppColors.lightBorder,
        thickness: 1,
        space:     0,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor:  AppColors.darkForest,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightBg1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.lightText1,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.lightText2,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightBg1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cream,
        selectedColor:   AppColors.sage,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText1,
        ),
        side:  const BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      textTheme: const TextTheme(
        displayLarge:   TextStyle(fontFamily: 'Inter', fontSize: 38, fontWeight: FontWeight.w800, color: AppColors.lightText1),
        displayMedium:  TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.lightText1),
        headlineLarge:  TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.lightText1),
        headlineMedium: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.lightText1),
        headlineSmall:  TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.lightText1),
        titleMedium:    TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.lightText1),
        titleSmall:     TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.lightText1),
        bodyMedium:     TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.lightText1),
        bodySmall:      TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.lightText2),
        labelMedium:    TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.lightText2),
        labelSmall:     TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.lightText3),
      ),
    );
  }
}
