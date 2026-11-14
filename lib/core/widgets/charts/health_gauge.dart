import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class HealthGauge extends StatelessWidget {
  const HealthGauge({
    super.key,
    required this.value,
    required this.unit,
    this.label,
    this.min = 0,
    this.max = 100,
    this.baselineMin,
    this.baselineMax,
    this.status = HealthTone.normal,
    this.size = AppDimensions.gaugeSize,
    this.available = true,
  });

  final double value;
  final String unit;
  final String? label;
  final double min;
  final double max;
  final double? baselineMin;
  final double? baselineMax;
  final HealthTone status;
  final double size;

  /// When false the gauge is shown in a neutral "no reading" state. The
  /// [value] is not rendered, so missing data is never presented as zero.
  final bool available;

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.status(status) : AppColors.unavailable;
    final normalized =
        available ? ((value - min) / (max - min)).clamp(0.0, 1.0) : 0.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              progress: normalized,
              color: color,
              trackColor: AppColors.border,
              baselineMin: baselineMin,
              baselineMax: baselineMax,
              min: min,
              max: max,
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  available
                      ? (value == value.roundToDouble()
                          ? value.round().toString()
                          : value.toStringAsFixed(1))
                      : '—',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.metric.copyWith(
                    color: color,
                    fontSize: size * 0.26,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                if (available && unit.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    unit,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: size * 0.09,
                    ),
                  ),
                ],
                if (label != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size * 0.12),
                    child: Text(
                      label!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: available
                            ? AppColors.textSecondary
                            : AppColors.textMuted,
                        fontSize: size * 0.09,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.min,
    required this.max,
    this.baselineMin,
    this.baselineMax,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double min;
  final double max;
  final double? baselineMin;
  final double? baselineMax;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    const startAngle = 135 * math.pi / 180;
    const sweep = 270 * math.pi / 180;

    canvas.drawArc(rect, startAngle, sweep, false, trackPaint);
    canvas.drawArc(rect, startAngle, sweep * progress, false, progressPaint);

    if (baselineMin != null) {
      _drawMarker(canvas, center, radius, baselineMin!);
    }
    if (baselineMax != null) {
      _drawMarker(canvas, center, radius, baselineMax!);
    }
  }

  void _drawMarker(Canvas canvas, Offset center, double radius, double value) {
    final t = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final angle = 135 * math.pi / 180 + 270 * math.pi / 180 * t;
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);
    canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppColors.textMuted);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
