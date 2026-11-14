import '../models/blood_pressure_reading.dart';
import '../models/body_region.dart';
import '../models/health_metric_id.dart';
import '../models/health_reading.dart';
import '../models/health_status.dart';
import '../models/today_snapshot.dart';
import 'mock_clock.dart';

abstract final class MockToday {
  static final TodaySnapshot snapshot = TodaySnapshot(
    greetingName: 'ASTRO_01',
    bloodPressure: BloodPressureReading(
      systolic: 118,
      diastolic: 76,
      recordedAt: MockClock.now,
      status: HealthStatus.normal,
    ),
    metrics: [
      HealthReading(
        metric: HealthMetricId.heartRate,
        value: 64,
        recordedAt: MockClock.now,
        status: HealthStatus.normal,
        label: 'Heart rate',
        unit: 'bpm',
      ),
      HealthReading(
        metric: HealthMetricId.bloodPressure,
        value: 118,
        secondaryValue: 76,
        recordedAt: MockClock.now,
        status: HealthStatus.normal,
        label: 'Blood pressure',
        unit: 'mmHg',
      ),
      HealthReading(
        metric: HealthMetricId.oxygen,
        value: 98,
        recordedAt: MockClock.now,
        status: HealthStatus.normal,
        label: 'Oxygen',
        unit: '%',
      ),
      HealthReading(
        metric: HealthMetricId.temperature,
        value: 36.6,
        recordedAt: MockClock.now,
        status: HealthStatus.normal,
        label: 'Temperature',
        unit: '°C',
      ),
      HealthReading(
        metric: HealthMetricId.sleep,
        value: 6.1,
        recordedAt: MockClock.now,
        status: HealthStatus.warning,
        label: 'Sleep last night',
        unit: 'h',
      ),
      HealthReading(
        metric: HealthMetricId.mood,
        value: 4,
        recordedAt: MockClock.now,
        status: HealthStatus.normal,
        label: 'Mood today',
        unit: '/5',
      ),
    ],
    bodyRegions: const [
      BodyRegion(
        id: 'head',
        label: 'Oxygen',
        status: HealthStatus.normal,
        note: 'Oxygen saturation is within expected range.',
        relativeX: 0.50,
        relativeY: 0.08,
      ),
      BodyRegion(
        id: 'chest-hr',
        label: 'Heart rate',
        status: HealthStatus.normal,
        note: 'Resting heart rate is within your personal baseline.',
        relativeX: 0.42,
        relativeY: 0.28,
      ),
      BodyRegion(
        id: 'chest-bp',
        label: 'Blood pressure',
        status: HealthStatus.normal,
        note: 'Blood pressure is within your personal baseline.',
        relativeX: 0.58,
        relativeY: 0.34,
      ),
      BodyRegion(
        id: 'abdomen',
        label: 'Temperature',
        status: HealthStatus.normal,
        note: 'Body temperature is within your personal baseline.',
        relativeX: 0.50,
        relativeY: 0.44,
      ),
    ],
    attentionNote: 'Everything else is within your personal baseline.',
  );
}