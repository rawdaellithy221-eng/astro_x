import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppColors.background),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.button,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppDimensions.touchTarget),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.background,
          disabledBackgroundColor: AppColors.cyan.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
          ),
        ),
        child: child,
      ),
    );
  }
}
