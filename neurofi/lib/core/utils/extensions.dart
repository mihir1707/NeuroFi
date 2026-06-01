import 'package:flutter/material.dart';

extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleCase {
    return split(' ').map((w) => w.capitalize).join(' ');
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

extension DoubleExtension on double {
  bool get isPositive => this > 0;
  bool get isNegative => this < 0;

  double get clampToPositive => clamp(0, double.infinity).toDouble();

  double toPrecision(int decimals) {
    return double.parse(toStringAsFixed(decimals));
  }
}

extension ColorExtension on Color {
  Color withOpacityValue(double opacity) {
    return withOpacity(opacity);
  }

  Color get lighter => Color.lerp(this, Colors.white, 0.2) ?? this;
  Color get darker  => Color.lerp(this, Colors.black, 0.2) ?? this;
}

extension DateExtension on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay   => DateTime(year, month, day, 23, 59, 59);
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull  => isEmpty ? null : last;

  List<T> safeSublist(int start, [int? end]) {
    if (start >= length) return [];
    final e = end != null ? end.clamp(0, length) : length;
    return sublist(start, e);
  }
}

extension BuildContextExtension on BuildContext {
  double get screenWidth  => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void pop([dynamic result]) => Navigator.pop(this, result);

  Future<T?> push<T>(Widget page) => Navigator.push<T>(
        this,
        MaterialPageRoute(builder: (_) => page),
      );
}
