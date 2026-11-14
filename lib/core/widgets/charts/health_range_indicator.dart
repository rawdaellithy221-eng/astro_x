import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../theme/app_text_styles.dart';

class HealthRangeIndicator extends StatelessWidget {
  const HealthRangeIndicator({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.baselineMin,
    this.baselineMax,
    this.color = AppColors.cyan,
    this.label,
  });

  final double value;
  final double min;
  final double max;
  final double? baselineMin;
  final double? baselineMax;
  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label!, style: AppTextStyles.caption),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            double pos(double v) => ((v - min) / (max - min)).clamp(0.0, 1.0) * width;
            return SizedBox(
              height: 26,
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    margin: const EdgeInsets.only(top: 9),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  if (baselineMin != null && baselineMax != null)
                    Positioned(
                      left: pos(baselineMin!),
                      width: (pos(baselineMax!) - pos(baselineMin!)).clamp(0.0, width),
                      top: 9,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  Positioned(
                    left: (pos(value) - 6).clamp(0.0, width - 12),
                    top: 3,
                    child: Container(
                      width: 12,
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(min.toStringAsFixed(0), style: AppTextStyles.caption.copyWith(fontSize: 9)),
            Text(max.toStringAsFixed(0), style: AppTextStyles.caption.copyWith(fontSize: 9)),
          ],
        ),
      ],
    );
  }
}
