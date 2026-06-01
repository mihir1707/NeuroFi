class CurrencyFormatter {
  static const Map<String, String> _symbols = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'AED': 'د.إ',
    'SGD': 'S\$',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CNY': '¥',
    'CHF': 'Fr',
    'KRW': '₩',
    'BTC': '₿',
  };

  static String symbolFor(String currencyCode) {
    return _symbols[currencyCode.toUpperCase()] ?? currencyCode;
  }

  static String format(double amount, String currencyCode, {bool showSign = false}) {
    final sym       = symbolFor(currencyCode);
    final formatted = _formatNumber(amount.abs());
    if (showSign) {
      return amount >= 0 ? '+$sym$formatted' : '-$sym$formatted';
    }
    return '$sym$formatted';
  }

  static String formatIncome(double amount, String currencyCode) {
    return '+${symbolFor(currencyCode)}${_formatNumber(amount)}';
  }

  static String formatExpense(double amount, String currencyCode) {
    return '-${symbolFor(currencyCode)}${_formatNumber(amount)}';
  }

  static String formatCompact(double amount, String currencyCode) {
    final sym = symbolFor(currencyCode);
    if (amount >= 10000000) return '$sym${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000)   return '$sym${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)     return '$sym${(amount / 1000).toStringAsFixed(1)}K';
    return '$sym${amount.toStringAsFixed(0)}';
  }

  static String formatWithDecimal(double amount, String currencyCode) {
    final sym = symbolFor(currencyCode);
    return '$sym${amount.toStringAsFixed(2)}';
  }

  static String _formatNumber(double amount) {
    final parts  = amount.toStringAsFixed(0).split('');
    final result = StringBuffer();
    int count    = 0;

    for (int i = parts.length - 1; i >= 0; i--) {
      if (count > 0) {
        if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
          result.write(',');
        }
      }
      result.write(parts[i]);
      count++;
    }

    return result.toString().split('').reversed.join();
  }
}
