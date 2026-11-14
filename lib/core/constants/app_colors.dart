import 'package:flutter/material.dart';

/// AstroX dark space-health palette from the approved design references.
abstract final class AppColors {
  static const Color background = Color(0xFF070B18);
  static const Color sidebar = Color(0xFF080C1B);
  static const Color sidebarSelected = Color(0x3322D3EE);
  static const Color surface = Color(0xFF10182E);
  static const Color surfaceAlt = Color(0xFF141E38);
  static const Color card = Color(0xFF121A32);
  static const Color cardElevated = Color(0xFF182240);

  static const Color border = Color(0x1FFFFFFF);
  static const Color borderStrong = Color(0x33FFFFFF);
  static const Color borderCyan = Color(0x6622D3EE);

  static const Color cyan = Color(0xFF2EE6FF);
  static const Color cyanDim = Color(0xFF22D3EE);
  static const Color cyanMuted = Color(0x3322D3EE);
  static const Color green = Color(0xFF34D399);
  static const Color greenMuted = Color(0x3334D399);
  static const Color orange = Color(0xFFFBBF24);
  static const Color orangeMuted = Color(0x33FBBF24);
  static const Color red = Color(0xFFF87171);
  static const Color redMuted = Color(0x33F87171);
  static const Color purple = Color(0xFFA78BFA);
  static const Color purpleMuted = Color(0x33A78BFA);

  /// Neutral gray used when no reading is available.
  static const Color unavailable = Color(0xFF6B7280);
  static const Color unavailableMuted = Color(0x336B7280);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xB8F8FAFC);
  static const Color textMuted = Color(0x73F8FAFC);

  static const Color overlay = Color(0x66000000);
  static const Color white = Color(0xFFFFFFFF);

  static Color status(HealthTone tone) {
    return switch (tone) {
      HealthTone.normal => green,
      HealthTone.warning => orange,
      HealthTone.critical => red,
      HealthTone.info => cyan,
      HealthTone.mood => purple,
      HealthTone.neutral => unavailable,
    };
  }
}

enum HealthTone { normal, warning, critical, info, mood, neutral }
