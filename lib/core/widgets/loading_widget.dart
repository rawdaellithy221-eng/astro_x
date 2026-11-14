import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../theme/app_text_styles.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 12),
          Text(message ?? AppStrings.loading, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
