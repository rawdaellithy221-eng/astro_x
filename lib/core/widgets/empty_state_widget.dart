import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../theme/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.message,
    this.icon = Icons.insights_outlined,
  });

  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 28),
            const SizedBox(height: 10),
            Text(
              message ?? AppStrings.emptyChart,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
