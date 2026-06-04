import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {

  // ─────────────────────────────────────────────────────
  // B&W DARK THEME
  // ─────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.black,

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Color(0x33FFFFFF),
        selectionHandleColor: Colors.white,
      ),
      fontFamily: 'Inter',

      colorScheme: const ColorScheme.dark(
        primary:     Colors.white,
        secondary:   Color(0xFFB0B0B0),
        surface:     Color(0xFF0A0A0A),
        error:       AppColors.red,
        onPrimary:   Colors.black,
        onSurface:   Colors.white,
        onSecondary: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor:  Colors.black,
        elevation:        0,
        centerTitle:      true,
        titleTextStyle:   AppTextStyles.headingSmall,
        iconTheme:        IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor:          Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      cardTheme: CardThemeData(
        color:     Color(0xFF0A0A0A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Color(0x26FFFFFF)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: Colors.black,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: const Color.fromARGB(255, 133, 130, 130)),
        labelStyle: AppTextStyles.labelMedium.copyWith(
            color: const Color.fromARGB(255, 133, 130, 130)),
        floatingLabelStyle: AppTextStyles.labelMedium.copyWith(
            color: Colors.white, fontSize: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 209, 205, 205)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 233, 226, 226)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 223, 193, 193)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: AppTextStyles.labelSmall.copyWith(
            color: const Color.fromARGB(255, 223, 193, 193)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
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
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.titleSmall,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.titleSmall,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:     Colors.black,
        selectedItemColor:   Colors.white,
        unselectedItemColor: Color(0x59FFFFFF),
        elevation:           0,
        type:                BottomNavigationBarType.fixed,
      ),

      dividerTheme: const DividerThemeData(
        color:     Color(0x1AFFFFFF),
        thickness: 1,
        space:     0,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor:  const Color(0xFF111111),
        contentTextStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0x26FFFFFF))),
        titleTextStyle:   AppTextStyles.headingSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: Color(0x26FFFFFF)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF111111),
        selectedColor:   Colors.white,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: Colors.white),
        side:        const BorderSide(color: Color(0x26FFFFFF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      textTheme: TextTheme(
        displayLarge:   AppTextStyles.displayLarge.copyWith(color: Colors.white),
        displayMedium:  AppTextStyles.displayMedium.copyWith(color: Colors.white),
        headlineLarge:  AppTextStyles.headingLarge.copyWith(color: Colors.white),
        headlineMedium: AppTextStyles.headingMedium.copyWith(color: Colors.white),
        headlineSmall:  AppTextStyles.headingSmall.copyWith(color: Colors.white),
        titleMedium:    AppTextStyles.titleMedium.copyWith(color: Colors.white),
        titleSmall:     AppTextStyles.titleSmall.copyWith(color: Colors.white),
        bodyMedium:     AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        bodySmall:      AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFFB0B0B0)),
        labelMedium:    AppTextStyles.labelMedium.copyWith(
            color: const Color(0xFF888888)),
        labelSmall:     AppTextStyles.labelSmall.copyWith(
            color: const Color(0xFF666666)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // LIGHT THEME (kept intact)
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
          fontFamily: 'Inter', fontSize: 12, color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightBg1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 16,
          fontWeight: FontWeight.w700, color: AppColors.lightText1,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter', fontSize: 13, color: AppColors.lightText2,
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
          fontFamily: 'Inter', fontSize: 11,
          fontWeight: FontWeight.w600, color: AppColors.lightText1,
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
