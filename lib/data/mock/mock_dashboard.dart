import '../models/health_metric_id.dart';
import '../models/selected_area_details.dart';

abstract final class MockDashboard {
  static const Map<String, SelectedAreaDetails> regionDetails = {
    'head': SelectedAreaDetails(
      title: 'Oxygen (SpO2)',
      statusLabel: 'Normal',
      description: 'Oxygen saturation is within expected range.',
      readings: ['Current reading: 98%'],
      baseline: '96-100%',
      whyInSpace: 'Cabin air quality and activity level can influence oxygen saturation.',
      recommendedAction: 'No action needed. Continue routine monitoring.',
    ),
    'chest-hr': SelectedAreaDetails(
      title: 'Heart rate',
      statusLabel: 'Normal',
      description: 'Resting heart rate is within your personal baseline.',
      readings: ['Current reading: 64 bpm'],
      baseline: '62 bpm',
      whyInSpace: 'A week-long rise in resting heart rate can follow short sleep or extra load.',
      recommendedAction: 'Protect tonight\'s sleep and re-check tomorrow morning.',
    ),
    'chest-bp': SelectedAreaDetails(
      title: 'Blood pressure',
      statusLabel: 'Normal',
      description: 'Blood pressure is within your personal baseline.',
      readings: ['Current reading: 118/76 mmHg'],
      baseline: '116/75 mmHg',
      whyInSpace: 'In weightlessness fluid shifts toward the head and the heart works against less gravity.',
      recommendedAction: 'Drink fluids and keep up the daily exercise routine.',
    ),
    'abdomen': SelectedAreaDetails(
      title: 'Temperature',
      statusLabel: 'Normal',
      description: 'Body temperature is within your personal baseline.',
      readings: ['Current reading: 36.6 °C'],
      baseline: '36.5 °C',
      whyInSpace: 'Fever in closed-loop air needs an early flag.',
      recommendedAction: 'Monitor if temperature rises above 37.2 °C.',
    ),
  };

  static const Map<HealthMetricId, SelectedAreaDetails> metricDetails = {
    HealthMetricId.heartRate: SelectedAreaDetails(
      title: 'Heart rate',
      statusLabel: 'Normal',
      description: 'Resting heart rate is within your personal baseline.',
      readings: ['Current reading: 64 bpm'],
      baseline: '62 bpm',
      whyInSpace: 'A week-long rise in resting heart rate can follow short sleep or extra load.',
      recommendedAction: 'Protect tonight\'s sleep and re-check tomorrow morning.',
    ),
    HealthMetricId.bloodPressure: SelectedAreaDetails(
      title: 'Blood pressure',
      statusLabel: 'Normal',
      description: 'Blood pressure is within your personal baseline.',
      readings: ['Current reading: 118/76 mmHg'],
      baseline: '116/75 mmHg',
      whyInSpace: 'In weightlessness fluid shifts toward the head and the heart works against less gravity.',
      recommendedAction: 'Drink fluids and keep up the daily exercise routine.',
    ),
    HealthMetricId.oxygen: SelectedAreaDetails(
      title: 'Oxygen (SpO2)',
      statusLabel: 'Normal',
      description: 'Oxygen saturation is within expected range.',
      readings: ['Current reading: 98%'],
      baseline: '96-100%',
      whyInSpace: 'Cabin air quality and activity level can influence oxygen saturation.',
      recommendedAction: 'No action needed. Continue routine monitoring.',
    ),
    HealthMetricId.temperature: SelectedAreaDetails(
      title: 'Temperature',
      statusLabel: 'Normal',
      description: 'Body temperature is within your personal baseline.',
      readings: ['Current reading: 36.6 °C'],
      baseline: '36.5 °C',
      whyInSpace: 'Fever in closed-loop air needs an early flag.',
      recommendedAction: 'Monitor if temperature rises above 37.2 °C.',
    ),
    HealthMetricId.sleep: SelectedAreaDetails(
      title: 'Sleep last night',
      statusLabel: 'Watch',
      description: 'Sleep duration is below your goal.',
      readings: ['Current reading: 6.1 hours'],
      baseline: 'Goal: 7 to 9 hours',
      whyInSpace: 'Short sleep can raise resting heart rate the next day.',
      recommendedAction: 'Protect tonight\'s sleep and dim cabin lights 45 minutes before bed.',
    ),
    HealthMetricId.mood: SelectedAreaDetails(
      title: 'Mood today',
      statusLabel: 'Normal',
      description: 'Mood has been steady for 5 days.',
      readings: ['Current reading: 4/5'],
      baseline: '3 to 5',
      whyInSpace: 'Mood streaks help separate isolation load from medical change.',
      recommendedAction: 'Continue current routine and check in daily.',
    ),
  };

  static const Map<String, List<HealthMetricId>> regionMetrics = {
    'head': [HealthMetricId.oxygen],
    'chest-hr': [HealthMetricId.heartRate],
    'chest-bp': [HealthMetricId.bloodPressure],
    'abdomen': [HealthMetricId.temperature],
    'sleep': [HealthMetricId.sleep],
  };
}