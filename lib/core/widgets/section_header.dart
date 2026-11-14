import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.overline,
  });

  final String title;
  final String? subtitle;
  final String? overline;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overline != null) ...[
                Text(overline!.toUpperCase(), style: AppTextStyles.overline),
                const SizedBox(height: AppDimensions.space8),
              ],
              Text(title, style: AppTextStyles.title),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
