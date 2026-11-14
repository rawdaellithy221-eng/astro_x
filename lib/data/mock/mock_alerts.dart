import '../models/alert_item.dart';
import '../models/health_status.dart';
import 'mock_clock.dart';

abstract final class MockAlerts {
  static final List<AlertItem> all = [
    AlertItem(
      id: 'alert-low-bp',
      title: 'Low blood pressure with dizziness',
      summary:
          'A seated reading of 86/56 with dizziness. Recheck after 5 minutes of rest.',
      severity: AlertSeverity.critical,
      createdAt: MockClock.now.subtract(const Duration(days: 12)),
      systolic: 86,
      diastolic: 56,
      heartRate: 98,
      oxygen: 98,
      guidance: const [
        'Sit or float still for 5 minutes, then measure again.',
        'Drink fluids and keep the arm relaxed until the cuff deflates.',
        'If dizzy, measure again after 5 minutes and write down how you felt.',
        'Flag the medical officer if the second reading stays below 90/60.',
      ],
    ),
    AlertItem(
      id: 'alert-hr-rise',
      title: 'Resting heart rate rising 7 days',
      summary: 'Resting heart rate is up 12 bpm versus last week.',
      severity: AlertSeverity.warning,
      createdAt: MockClock.now.subtract(const Duration(hours: 6)),
      heartRate: 74,
      guidance: const [
        'Protect tonight’s sleep.',
        'Drink fluids and skip extra caffeine.',
        'Re-check resting heart rate tomorrow morning.',
      ],
    ),
    AlertItem(
      id: 'alert-sleep',
      title: 'Short sleep streak',
      summary: 'Average 6.0 h this week versus 7.1 h before.',
      severity: AlertSeverity.warning,
      createdAt: MockClock.now.subtract(const Duration(hours: 10)),
      isUnread: false,
      guidance: const [
        'Keep the pre-sleep wind-down window.',
        'Dim cabin lights 45 minutes before sleep.',
      ],
    ),
  ];

  static int get unreadCount => all.where((item) => item.isUnread).length;
}
