import 'package:intl/intl.dart';

abstract final class DateFormatters {
  static final DateFormat shortMonthDay = DateFormat('MMM d');
  static final DateFormat chartTick = DateFormat('MMM d');
  static final DateFormat full = DateFormat('MMM d, yyyy');

  static String rangeLabel(DateTime start, DateTime end) {
    return '${shortMonthDay.format(start)} – ${shortMonthDay.format(end)}';
  }
}
