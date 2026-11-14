import 'package:flutter/material.dart';

import '../../../data/models/health_status.dart';

import '../../helper/health_status_helper.dart';
import '../status_badge.dart';

class HealthStatusBadge extends StatelessWidget {
  const HealthStatusBadge({super.key, required this.status, this.label});

  final HealthStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final resolved =
        label ??
        switch (status) {
          HealthStatus.normal => 'Normal',
          HealthStatus.warning => 'Warning',
          HealthStatus.critical => 'Critical',
          HealthStatus.unknown => 'Unavailable',
        };

    return StatusBadge(
      label: resolved,
      tone: HealthStatusHelper.toneFor(status),
      icon: switch (status) {
        HealthStatus.normal => Icons.check_circle_outline,
        HealthStatus.warning => Icons.warning_amber_rounded,
        HealthStatus.critical => Icons.error_outline,
        HealthStatus.unknown => Icons.remove_circle_outline,
      },
    );
  }
}

class HealthToneBadge extends StatusBadge {
  const HealthToneBadge({
    super.key,
    required super.label,
    required super.tone,
    super.icon,
  });
}
