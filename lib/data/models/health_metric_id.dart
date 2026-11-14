enum HealthMetricId {
  heartRate,
  bloodPressure,
  oxygen,
  temperature,
  sleep,
  mood,
  weight,
  exercise,
}

extension HealthMetricIdX on HealthMetricId {
  String get label {
    return switch (this) {
      HealthMetricId.heartRate => 'Heart rate',
      HealthMetricId.bloodPressure => 'Blood pressure',
      HealthMetricId.oxygen => 'Oxygen',
      HealthMetricId.temperature => 'Temperature',
      HealthMetricId.sleep => 'Sleep',
      HealthMetricId.mood => 'Mood',
      HealthMetricId.weight => 'Weight',
      HealthMetricId.exercise => 'Exercise',
    };
  }

  String get unit {
    return switch (this) {
      HealthMetricId.heartRate => 'bpm',
      HealthMetricId.bloodPressure => 'mmHg',
      HealthMetricId.oxygen => '%',
      HealthMetricId.temperature => '°C',
      HealthMetricId.sleep => 'h',
      HealthMetricId.mood => '1–5',
      HealthMetricId.weight => 'kg',
      HealthMetricId.exercise => 'min',
    };
  }
}
