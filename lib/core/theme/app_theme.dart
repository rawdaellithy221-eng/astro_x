import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.cyan,
        secondary: AppColors.green,
        error: AppColors.red,
        onPrimary: AppColors.background,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),
      textTheme: const TextTheme(
        displaySmall: AppTextStyles.display,
        headlineMedium: AppTextStyles.title,
        titleMedium: AppTextStyles.titleSm,
        bodyMedium: AppTextStyles.body,
        labelLarge: AppTextStyles.button,
        labelSmall: AppTextStyles.overline,
      ),
      dividerColor: AppColors.border,
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _inputBorder(AppColors.border),
        enabledBorder: _inputBorder(AppColors.border),
        focusedBorder: _inputBorder(AppColors.cyanDim),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderStrong),
        ),
        textStyle: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radius12),
      borderSide: BorderSide(color: color),
    );
  }

  static BoxDecoration cardDecoration({
    Color? color,
    Color? borderColor,
    double radius = AppDimensions.radius16,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.border),
    );
  }
}
