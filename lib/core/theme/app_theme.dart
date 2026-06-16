import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:termchat_app/core/theme/app_colors.dart';
import 'package:termchat_app/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light({String fontSize = 'sm'}) =>
      _buildTheme(false, fontSize);

  static ThemeData dark({String fontSize = 'sm'}) =>
      _buildTheme(true, fontSize);

  static ThemeData _buildTheme(bool isDark, String fontSize) {
    double scaleFactor = 1.0;
    if (fontSize == 'md') {
      scaleFactor = 1.15;
    } else if (fontSize == 'lg') {
      scaleFactor = 1.3;
    }
    final background = isDark ? AppColors.bgAppDark : AppColors.bgAppLight;

    final surface = isDark ? AppColors.bgSurfaceDark : AppColors.bgSurfaceLight;

    final elevated = isDark
        ? AppColors.bgElevatedDark
        : AppColors.bgElevatedLight;

    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final tertiaryText = isDark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiaryLight;

    final border = isDark
        ? AppColors.borderDefaultDark
        : AppColors.borderDefaultLight;

    final strongBorder = isDark
        ? AppColors.borderStrongDark
        : AppColors.borderStrongLight;

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,

      primary: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      onPrimary: Colors.white,

      secondary: isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
      onSecondary: Colors.black,

      tertiary: isDark ? AppColors.successDark : AppColors.successLight,
      onTertiary: Colors.white,

      error: isDark ? AppColors.errorDark : AppColors.errorLight,
      onError: Colors.white,

      surface: surface,
      onSurface: primaryText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,

      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: elevated,
      dividerColor: border,

      textTheme: TextTheme(
        displayLarge: AppTextStyles.roomCode.copyWith(color: primaryText),
        displayMedium: AppTextStyles.roomCode.copyWith(color: primaryText),
        displaySmall: AppTextStyles.roomCode.copyWith(color: primaryText),

        headlineLarge: AppTextStyles.roomCode.copyWith(color: primaryText),
        headlineMedium: AppTextStyles.roomCode.copyWith(color: primaryText),
        headlineSmall: AppTextStyles.roomCode.copyWith(color: primaryText),

        titleLarge: AppTextStyles.username.copyWith(color: primaryText),
        titleMedium: AppTextStyles.username.copyWith(color: primaryText),
        titleSmall: AppTextStyles.username.copyWith(color: primaryText),

        bodyLarge: AppTextStyles.message.copyWith(color: primaryText),
        bodyMedium: AppTextStyles.message.copyWith(color: primaryText),
        bodySmall: AppTextStyles.meta.copyWith(color: secondaryText),

        labelLarge: AppTextStyles.username.copyWith(color: primaryText),
        labelMedium: AppTextStyles.meta.copyWith(color: secondaryText),
        labelSmall: AppTextStyles.meta.copyWith(color: tertiaryText),
      ).apply(fontSizeFactor: scaleFactor),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: primaryText,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.roomCode.copyWith(color: primaryText),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: elevated,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,

        hintStyle: AppTextStyles.placeholder.copyWith(color: tertiaryText),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: strongBorder, width: 1),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.username,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryText,
          textStyle: AppTextStyles.username,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTextStyles.username,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: primaryText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: elevated,
        selectedColor: colorScheme.primary.withValues(alpha: .15),
        side: BorderSide(color: border),
        labelStyle: AppTextStyles.meta.copyWith(color: primaryText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: elevated,
        contentTextStyle: AppTextStyles.message.copyWith(color: primaryText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
      ),

      dividerTheme: DividerThemeData(color: border, thickness: 1),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
