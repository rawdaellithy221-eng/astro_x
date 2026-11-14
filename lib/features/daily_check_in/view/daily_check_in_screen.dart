import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/common_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/charts/health_range_indicator.dart';
import '../../../data/models/check_in_step.dart';
import '../../../core/database/app_database.dart';
import '../../../data/models/health_metric_id.dart';
import '../../../data/models/health_status.dart' show CheckInContext;
import '../../../data/repositories/health_data_repository.dart';
import '../../../data/repositories/health_repository.dart';
import '../../../features/user/cubit/user_cubit.dart';
import '../cubit/daily_check_in_cubit.dart';

String _illustrationFor(HealthMetricId metric) {
  return switch (metric) {
    HealthMetricId.bloodPressure => 'assets/images/check_in/blood_pressure.svg',
    HealthMetricId.heartRate => 'assets/images/check_in/heart_rate.svg',
    HealthMetricId.oxygen => 'assets/images/check_in/oxygen.svg',
    HealthMetricId.temperature => 'assets/images/check_in/temperature.svg',
    HealthMetricId.sleep => 'assets/images/check_in/sleep.svg',
    HealthMetricId.mood => 'assets/images/check_in/mood.svg',
    HealthMetricId.exercise => 'assets/images/check_in/exercise_food.svg',
    _ => 'assets/images/check_in/exercise_food.svg',
  };
}

class DailyCheckInScreen extends StatelessWidget {
  const DailyCheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final userId = context.read<UserCubit>().state.userId;
    if (userId == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.cyan),
      );
    }
    return BlocProvider(
      create: (_) => DailyCheckInCubit(
        healthRepository: HealthDataRepository(db),
        userId: userId,
      )..load(),
      child: const _DailyCheckInView(),
    );
  }
}

class _DailyCheckInView extends StatelessWidget {
  const _DailyCheckInView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyCheckInCubit, DailyCheckInState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.cyan),
          );
        }
        if (state.finished) {
          return _FinishedView(
            onRestart: () => context.read<DailyCheckInCubit>().restart(),
          );
        }
        final step = state.currentStep!;
        final cubit = context.read<DailyCheckInCubit>();
        final baseline = const HealthRepository().baseline(step.metric);
        final min = baseline.min;
        final max = baseline.max == baseline.min
            ? baseline.min + 40
            : baseline.max;
        final currentValue =
            double.tryParse(state.values[step.metric.name] ?? '') ??
            baseline.min;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 1200;
              final left = _LeftSteps(state: state, cubit: cubit);
              final center = _CenterMeasurement(
                step: step,
                state: state,
                cubit: cubit,
                min: min,
                max: max,
                currentValue: currentValue,
              );
              final right = _RightInstructions(step: step);

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

class _LeftSteps extends StatelessWidget {
  const _LeftSteps({required this.state, required this.cubit});
  final DailyCheckInState state;
  final DailyCheckInCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s steps', style: AppTextStyles.titleSm),
              const SizedBox(height: 8),
              ...state.steps.map((s) {
                final active = s.index == state.currentStep!.index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.cyanMuted : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: active ? AppColors.borderCyan : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: active
                              ? AppColors.cyan
                              : AppColors.surfaceAlt,
                          child: Text(
                            '${s.index}',
                            style: TextStyle(
                              color: active
                                  ? AppColors.background
                                  : AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s.title, style: AppTextStyles.bodyStrong),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space12),
        CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mission summary', style: AppTextStyles.titleSm),
              const SizedBox(height: 4),
              Text('Day 127 of 420 • Crew of 4', style: AppTextStyles.body),
              Text('Earth delay ~20 min', style: AppTextStyles.caption),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space12),
        CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Helpful information', style: AppTextStyles.titleSm),
              const SizedBox(height: 4),
              Text(
                'Complete all steps for an accurate daily snapshot.',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CenterMeasurement extends StatelessWidget {
  const _CenterMeasurement({
    required this.step,
    required this.state,
    required this.cubit,
    required this.min,
    required this.max,
    required this.currentValue,
  });
  final CheckInStep step;
  final DailyCheckInState state;
  final DailyCheckInCubit cubit;
  final double min;
  final double max;
  final double currentValue;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.title, style: AppTextStyles.title),
          const SizedBox(height: 4),
          Text(step.prompt, style: AppTextStyles.body),
          const SizedBox(height: AppDimensions.space16),
          _InputForStep(step: step, state: state, cubit: cubit),
          const SizedBox(height: AppDimensions.space16),
          HealthRangeIndicator(
            value: currentValue,
            min: min - 10,
            max: max + 10,
            baselineMin: min,
            baselineMax: max,
            label: 'Health range',
          ),
          const SizedBox(height: AppDimensions.space12),
          if (step.metric == HealthMetricId.bloodPressure) ...[
            Text('Measurement condition', style: AppTextStyles.bodyStrong),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: CheckInContext.values.map((c) {
                final label = c.name;
                final selected = state.values['context'] == label;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => cubit.setValue('context', label),
                  selectedColor: AppColors.cyanMuted,
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.space12),
          ],
          if (state.error != null) ...[
            Text(
              state.error!,
              style: AppTextStyles.body.copyWith(color: AppColors.red),
            ),
            const SizedBox(height: AppDimensions.space12),
          ],
          Row(
            children: [
              if (state.currentIndex > 0)
                Expanded(
                  child: SecondaryButton(
                    label: 'Back',
                    onPressed: cubit.back,
                    expand: true,
                  ),
                ),
              if (state.currentIndex > 0) const SizedBox(width: 8),
              if (state.currentIndex < state.steps.length - 1) ...[
                Expanded(
                  child: SecondaryButton(
                    label: 'Skip',
                    onPressed: cubit.skip,
                    expand: true,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: PrimaryButton(
                  label: state.currentIndex == state.steps.length - 1
                      ? 'Complete check-in'
                      : 'Save and next',
                  onPressed: cubit.next,
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

class _InputForStep extends StatelessWidget {
  const _InputForStep({
    required this.step,
    required this.state,
    required this.cubit,
  });
  final CheckInStep step;
  final DailyCheckInState state;
  final DailyCheckInCubit cubit;

  @override
  Widget build(BuildContext context) {
    switch (step.metric) {
      case HealthMetricId.bloodPressure:
        return Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Systolic',
                hint: '118',
                value: state.values['bp_sys'] ?? '',
                onChanged: (v) => cubit.setValue('bp_sys', v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Field(
                label: 'Diastolic',
                hint: '76',
                value: state.values['bp_dia'] ?? '',
                onChanged: (v) => cubit.setValue('bp_dia', v),
              ),
            ),
          ],
        );
      case HealthMetricId.oxygen:
        return _Field(
          label: 'Oxygen saturation (SpO₂)',
          hint: '98',
          value: state.values[HealthMetricId.oxygen.name] ?? '',
          onChanged: (v) => cubit.setValue(HealthMetricId.oxygen.name, v),
          suffix: '%',
        );
      case HealthMetricId.mood:
        return Wrap(
          spacing: 8,
          children: List.generate(5, (i) {
            final v = '${i + 1}';
            final selected = state.values['mood'] == v;
            return ChoiceChip(
              label: Text(v),
              selected: selected,
              onSelected: (_) => cubit.setValue('mood', v),
              selectedColor: AppColors.cyanMuted,
            );
          }),
        );
      default:
        return _Field(
          label: step.metric.label,
          hint: '',
          value: state.values[step.metric.name] ?? '',
          onChanged: (v) => cubit.setValue(step.metric.name, v),
        );
    }
  }
}

class _Field extends StatefulWidget {
  const _Field({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.suffix,
  });

  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final String? suffix;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _Field oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(), style: AppTextStyles.overline),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          keyboardType: TextInputType.numberWithOptions(
            decimal: widget.suffix != '%',
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: AppTextStyles.titleSm.copyWith(color: AppColors.cyan),
          decoration: InputDecoration(
            hintText: widget.hint,
            suffixText: widget.suffix,
          ),
        ),
      ],
    );
  }
}

class _RightInstructions extends StatelessWidget {
  const _RightInstructions({required this.step});
  final CheckInStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SizedBox(
                height: 160,
                child: SvgPicture.asset(
                  _illustrationFor(step.metric),
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.space12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How to measure', style: AppTextStyles.titleSm),
                    const SizedBox(height: 8),
                    ...step.howTo.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e.key + 1}. ',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.cyan,
                              ),
                            ),
                            Expanded(
                              child: Text(e.value, style: AppTextStyles.body),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.space12),
        CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why it matters', style: AppTextStyles.titleSm),
              const SizedBox(height: 4),
              Text(step.whyItMatters, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinishedView extends StatelessWidget {
  const _FinishedView({required this.onRestart});
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.green, size: 56),
            const SizedBox(height: 12),
            Text('Check-in saved on this device', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text(
              'Your readings are stored locally.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Start again', onPressed: onRestart),
          ],
        ),
      ),
    );
  }
}
