import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/models/alert_item.dart';
import '../../../data/models/health_status.dart' show AlertSeverity;
import '../cubit/alerts_cubit.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AlertsView();
  }
}

class _AlertsView extends StatelessWidget {
  const _AlertsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsCubit, AlertsState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.cyan),
          );
        }
        final selected = state.selected;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 1200;
              final left = _LeftAlertsList(state: state);
              final center = _CenterAlertDetail(alert: selected);
              final right = _RightAlertInfo(alert: selected);

              if (desktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: left),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(flex: 3, child: center),
                    const SizedBox(width: AppDimensions.space16),
                    Expanded(flex: 2, child: right),
                  ],
                );
              }
              return Column(
                children: [
                  left,
                  const SizedBox(height: 16),
                  center,
                  const SizedBox(height: 16),
                  right,
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _LeftAlertsList extends StatelessWidget {
  const _LeftAlertsList({required this.state});
  final AlertsState state;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active alerts', style: AppTextStyles.titleSm),
          const SizedBox(height: 8),
          if (state.filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No active alerts for the selected filter.',
                style: AppTextStyles.body,
              ),
            ),
          ...state.filtered.map((a) {
            final color = _color(a.severity);
            final selected = state.selectedId == a.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => context.read<AlertsCubit>().select(a.id),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.cyanMuted
                        : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.borderCyan : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_icon(a.severity), color: color, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              a.title,
                              style: AppTextStyles.bodyStrong,
                            ),
                          ),
                          if (a.isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.cyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(a.summary, style: AppTextStyles.caption),
                      const SizedBox(height: 2),
                      Text(
                        _timeAgo(a.createdAt),
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _color(AlertSeverity s) => switch (s) {
    AlertSeverity.critical => AppColors.red,
    AlertSeverity.warning => AppColors.orange,
    AlertSeverity.info => AppColors.cyan,
  };

  IconData _icon(AlertSeverity s) => switch (s) {
    AlertSeverity.critical => Icons.error_outline,
    AlertSeverity.warning => Icons.warning_amber_rounded,
    AlertSeverity.info => Icons.info_outline,
  };

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

class _CenterAlertDetail extends StatefulWidget {
  const _CenterAlertDetail({required this.alert});
  final AlertItem? alert;

  @override
  State<_CenterAlertDetail> createState() => _CenterAlertDetailState();
}

class _CenterAlertDetailState extends State<_CenterAlertDetail> {
  @override
  Widget build(BuildContext context) {
    final a = widget.alert;
    if (a == null) {
      return const CommonCard(child: Text('No alert selected'));
    }
    final color = switch (a.severity) {
      AlertSeverity.critical => AppColors.red,
      AlertSeverity.warning => AppColors.orange,
      AlertSeverity.info => AppColors.cyan,
    };
    return CommonCard(
      borderColor: color.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                a.severity == AlertSeverity.critical
                    ? Icons.error_outline
                    : Icons.warning_amber_rounded,
                color: color,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(a.title, style: AppTextStyles.title)),
            ],
          ),
          const SizedBox(height: 8),
          Text(a.summary, style: AppTextStyles.body),
          if (a.readingText != null) ...[
            const SizedBox(height: 12),
            Text('Triggering reading', style: AppTextStyles.bodyStrong),
            const SizedBox(height: 4),
            Text(a.readingText!, style: AppTextStyles.body),
          ],
          const SizedBox(height: 12),
          Text('Symptoms', style: AppTextStyles.bodyStrong),
          Text(
            'Report any dizziness, headache, or fatigue you noticed with this reading.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 12),
          Text('Guidance', style: AppTextStyles.bodyStrong),
          ...a.guidance.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${e.key + 1}. ',
                    style: AppTextStyles.body.copyWith(color: color),
                  ),
                  Expanded(child: Text(e.value, style: AppTextStyles.body)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Acknowledge',
                  onPressed: () {
                    context.read<AlertsCubit>().markRead(a.id);
                  },
                  expand: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SecondaryButton(
                  label: 'View history',
                  onPressed: () {},
                  expand: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RightAlertInfo extends StatelessWidget {
  const _RightAlertInfo({required this.alert});
  final AlertItem? alert;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why this alert fired', style: AppTextStyles.titleSm),
              const SizedBox(height: 6),
              Text(
                'Rule: the saved reading is outside the configured reference range for this metric.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 4),
              Text(
                'Reading: ${alert?.readingText ?? '--'}',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space12),
        CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report timing', style: AppTextStyles.titleSm),
              const SizedBox(height: 4),
              Text(
                'Logged ${alert != null ? _fmt(alert!.createdAt) : '--'}',
                style: AppTextStyles.body,
              ),
              Text(
                'Downlink window: next scheduled',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space12),
        CommonCard(
          color: AppColors.redMuted,
          borderColor: AppColors.red.withValues(alpha: 0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emergency',
                style: AppTextStyles.titleSm.copyWith(color: AppColors.red),
              ),
              const SizedBox(height: 4),
              Text(
                'Contact medical officer if symptoms worsen.',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime d) =>
      '${d.month}/${d.day} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}
