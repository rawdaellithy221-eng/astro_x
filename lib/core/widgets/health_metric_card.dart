import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import 'common_card.dart';
import 'status_badge.dart';
import 'charts/health_gauge.dart';

class HealthMetricCard extends StatelessWidget {
  const HealthMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    this.subtitle,
    this.trend,
    this.onTap,
    this.selected = false,
    this.gaugeMin = 0,
    this.gaugeMax = 100,
    this.baselineMin,
    this.baselineMax,
    this.available = true,
  });

  final String title;
  final double value;
  final String unit;
  final HealthTone status;
  final bool available;
  final String? subtitle;
  final String? trend;
  final VoidCallback? onTap;
  final bool selected;
  final double gaugeMin;
  final double gaugeMax;
  final double? baselineMin;
  final double? baselineMax;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      onTap: onTap,
      borderColor: selected ? AppColors.borderCyan : null,
      color: selected ? AppColors.surfaceAlt : null,
      padding: const EdgeInsets.all(AppDimensions.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HealthGauge(
            value: value,
            unit: unit,
            min: gaugeMin,
            max: gaugeMax,
            baselineMin: baselineMin,
            baselineMax: baselineMax,
            status: status,
            size: 60,
            available: available,
          ),
          const SizedBox(width: AppDimensions.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    StatusBadge(
                      label: switch (status) {
                        HealthTone.normal => 'Normal',
                        HealthTone.warning => 'Warning',
                        HealthTone.critical => 'Critical',
                        HealthTone.info => 'Info',
                        HealthTone.mood => 'Mood',
                        HealthTone.neutral => 'Unavailable',
                      },
                      tone: status,
                    ),
                    if (trend != null)
                      Text(
                        trend!,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
