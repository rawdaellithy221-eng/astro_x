import '../models/check_in_step.dart';
import '../models/health_metric_id.dart';

abstract final class MockCheckIn {
  static const List<CheckInStep> steps = [
    CheckInStep(
      index: 1,
      metric: HealthMetricId.bloodPressure,
      title: 'Blood pressure',
      prompt:
          'Sit or float still for 5 minutes, then measure. Enter both numbers.',
      howTo: [
        'Wrap the cuff snugly on your upper arm, level with your heart.',
        'Stay still and quiet. Do not talk or exercise for 5 minutes before.',
        'Press start and keep your arm relaxed until the cuff deflates.',
        'If dizzy, measure again after 5 minutes and write down how you felt.',
      ],
      whyItMatters: 'In weightlessness fluid moves toward the head and the heart works differently. Tracking pressure helps spot dizziness and heart risks early.',
    ),
    CheckInStep(
      index: 2,
      metric: HealthMetricId.heartRate,
      title: 'Heart rate',
      prompt:
          'Take a resting heart rate after you have been still for 5 minutes.',
      howTo: [
        'Sit or float quietly.',
        'Use the chest strap or optical sensor.',
        'Stay still until the reading settles.',
      ],
      whyItMatters: 'A week-long rise in resting heart rate can follow short sleep or extra load.',
    ),
    CheckInStep(
      index: 3,
      metric: HealthMetricId.temperature,
      title: 'Temperature',
      prompt: 'Record your current body temperature.',
      howTo: ['Use the assigned thermometer.', 'Wait until the device beeps.'],
      whyItMatters: 'Fever in closed-loop air needs an early flag.',
    ),
    CheckInStep(
      index: 4,
      metric: HealthMetricId.oxygen,
      title: 'Oxygen saturation (SpO₂)',
      prompt: 'Measure your oxygen saturation and enter the percentage shown.',
      howTo: [
        'Make sure your hand is warm and relaxed.',
        'Place the pulse oximeter on your fingertip with the display facing up.',
        'Keep your hand still until the reading settles, then enter the SpO₂ percentage.',
      ],
      whyItMatters: 'Oxygen saturation is one part of monitoring your wellbeing. Readings can be affected by movement, circulation, and sensor fit.',
    ),
    CheckInStep(
      index: 5,
      metric: HealthMetricId.sleep,
      title: 'Sleep',
      prompt: 'How many hours did you sleep last night?',
      howTo: ['Use the sleep log from your wearable, or type hours.'],
      whyItMatters: 'Short sleep can raise resting heart rate the next day.',
    ),
    CheckInStep(
      index: 6,
      metric: HealthMetricId.mood,
      title: 'Mood and symptoms',
      prompt: 'Rate mood from 1 to 5 and note dizziness, headache, or nausea.',
      howTo: ['Pick a mood score.', 'Add any symptoms that changed today.'],
      whyItMatters:
          'Mood streaks help separate isolation load from medical change.',
    ),
    CheckInStep(
      index: 7,
      metric: HealthMetricId.exercise,
      title: 'Exercise and food',
      prompt: 'Log exercise minutes and whether meals were complete.',
      howTo: [
        'Enter resistance and aerobic minutes.',
        'Mark meals as complete, partial, or skipped.',
      ],
      whyItMatters: 'Load and calories keep muscle and blood volume in range.',
    ),
  ];
}
