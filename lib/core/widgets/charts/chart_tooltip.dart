import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../../data/models/time_series_point.dart' show ChartLegendItem;
import '../../theme/app_text_styles.dart';

class ChartTooltip extends StatelessWidget {
  const ChartTooltip({
    super.key,
    required this.title,
    required this.lines,
  });

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space8),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          ...lines.map((l) => Text(l, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.items});

  final List<ChartLegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Color(item.colorValue),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(item.label, style: AppTextStyles.caption),
          ],
        );
      }).toList(),
    );
  }
}

