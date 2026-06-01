class DateFormatter {
  static String toDisplay(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return '${_monthName(date.month)} ${date.day}, ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  static String toDisplayWithTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      final time = _formatTime(date);
      return '${_monthName(date.month)} ${date.day}, ${date.year} · $time';
    } catch (_) {
      return isoDate;
    }
  }

  static String toRelative(String isoDate) {
    try {
      final date  = DateTime.parse(isoDate).toLocal();
      final now   = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final d     = DateTime(date.year, date.month, date.day);
      final diff  = today.difference(d).inDays;

      if (diff == 0) return 'Today, ${_formatTime(date)}';
      if (diff == 1) return 'Yesterday, ${_formatTime(date)}';
      if (diff < 7)  return '${_dayName(date.weekday)}, ${_formatTime(date)}';
      return '${_monthShort(date.month)} ${date.day}';
    } catch (_) {
      return isoDate;
    }
  }

  static String toApi(DateTime date) {
    return '${date.year}-${_pad(date.month)}-${_pad(date.day)}';
  }

  static String toApiWithTime(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  static String monthYear(DateTime date) {
    return '${_monthName(date.month)} ${date.year}';
  }

  static String monthShort(int month) => _monthShort(month);

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  static String _formatTime(DateTime date) {
    final hour   = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = _pad(date.minute);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  static String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  static String _monthShort(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  static String _dayName(int weekday) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday];
  }
}
