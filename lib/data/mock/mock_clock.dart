/// Frozen "mission now" so mock series never shift on rebuild.
abstract final class MockClock {
  static final DateTime now = DateTime(2025, 11, 13, 8, 12);
}
