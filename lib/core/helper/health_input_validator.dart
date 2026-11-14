/// Technical entry limits for a saved measurement.
///
/// These are deliberately separate from the healthy reference ranges used by
/// `HealthStatusHelper`. An abnormal but plausible reading must be accepted,
/// stored, and classified later; it must not be rejected just because it is
/// outside the healthy range.
abstract final class HealthInputValidator {
  // Blood pressure, in mmHg.
  static const int systolicMin = 40;
  static const int systolicMax = 300;
  static const int diastolicMin = 20;
  static const int diastolicMax = 200;

  // Heart rate, in bpm.
  static const int heartRateMin = 20;
  static const int heartRateMax = 250;

  // SpO2 is a percentage; this is a technical sensor input boundary, not a
  // health reference range.
  static const int oxygenMin = 0;
  static const int oxygenMax = 100;

  // Body temperature, in °C. This entry window is wider than the healthy
  // reference range so a high fever (including the reported 50 °C entry) is
  // preserved and marked as an alert instead of being rejected.
  static const double temperatureMin = 20;
  static const double temperatureMax = 50;

  // Sleep duration, in hours.
  static const double sleepMin = 0;
  static const double sleepMax = 24;

  // Mood is a fixed 1–5 scale.
  static const int moodMin = 1;
  static const int moodMax = 5;

  // Exercise, in minutes per day.
  static const double exerciseMin = 0;
  static const double exerciseMax = 1440;

  static int? parseInt(
    String raw, {
    required int min,
    required int max,
    required String label,
    required bool validate,
  }) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    final value = int.tryParse(text);
    if (value == null || value < min || value > max) {
      if (validate) throw FormatException('Enter a valid $label.');
      return null;
    }
    return value;
  }

  static double? parseDouble(
    String raw, {
    required double min,
    required double max,
    required String label,
    required bool validate,
  }) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    final value = double.tryParse(text);
    if (value == null || !value.isFinite || value < min || value > max) {
      if (validate) throw FormatException('Enter a valid $label.');
      return null;
    }
    return value;
  }

  static void validateBloodPressurePair(
    String systolicText,
    String diastolicText,
  ) {
    final hasSystolic = systolicText.trim().isNotEmpty;
    final hasDiastolic = diastolicText.trim().isNotEmpty;
    if (hasSystolic != hasDiastolic) {
      throw const FormatException('Enter both blood pressure numbers.');
    }
  }

  /// Accepts a minute count or a simple label plus minute count. Empty text
  /// means the optional step was skipped, not zero minutes.
  static double? exerciseMinutes(String raw, {required bool validate}) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    final match = RegExp(
      r'^(?:(?:resistance|aerobic)\s*)?(-?\d+(?:\.\d+)?)(?:\s*(?:min|mins|minutes))?$',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) {
      if (validate) {
        throw const FormatException('Enter exercise minutes as a number.');
      }
      return null;
    }

    final value = double.tryParse(match.group(1)!);
    if (value == null ||
        !value.isFinite ||
        value < exerciseMin ||
        value > exerciseMax) {
      if (validate) {
        throw const FormatException(
          'Enter exercise minutes between 0 and 1440.',
        );
      }
      return null;
    }
    return value;
  }
}
