/// Utility class for formatting prices and currency values
class PriceFormatter {
  // Currency symbol (can be made configurable based on locale)
  static const String defaultCurrencySymbol = '\$';

  /// Format price with currency symbol and 2 decimal places
  /// Example: 99.5 -> "\$99.50"
  static String formatPrice(double price, {String? currencySymbol}) {
    final symbol = currencySymbol ?? defaultCurrencySymbol;
    return '$symbol${price.toStringAsFixed(2)}';
  }

  /// Format price without currency symbol
  /// Example: 99.5 -> "99.50"
  static String formatPriceOnly(double price) {
    return price.toStringAsFixed(2);
  }

  /// Format price with custom decimal places
  /// Example: formatPriceWithDecimal(99.123, 1) -> "\$99.1"
  static String formatPriceWithDecimal(double price, int decimalPlaces,
      {String? currencySymbol}) {
    final symbol = currencySymbol ?? defaultCurrencySymbol;
    return '$symbol${price.toStringAsFixed(decimalPlaces)}';
  }

  /// Format large prices in abbreviated format
  /// Example: 1000 -> "\$1.0K", 1000000 -> "\$1.0M"
  static String formatPriceAbbreviated(double price, {String? currencySymbol}) {
    final symbol = currencySymbol ?? defaultCurrencySymbol;

    if (price >= 1000000) {
      return '$symbol${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '$symbol${(price / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${price.toStringAsFixed(2)}';
    }
  }

  /// Format price range
  /// Example: formatPriceRange(10, 100) -> "\$10.00 - \$100.00"
  static String formatPriceRange(double minPrice, double maxPrice,
      {String? currencySymbol}) {
    final symbol = currencySymbol ?? defaultCurrencySymbol;
    final min = minPrice.toStringAsFixed(2);
    final max = maxPrice.toStringAsFixed(2);
    return '$symbol$min - $symbol$max';
  }

  /// Format percentage discount
  /// Example: formatDiscount(20) -> "20% off"
  static String formatDiscount(double discountPercent) {
    return '${discountPercent.toStringAsFixed(0)}% off';
  }

  /// Format discount amount with currency
  /// Example: formatDiscountAmount(50) -> "Save \$50.00"
  static String formatDiscountAmount(double discountAmount,
      {String? currencySymbol}) {
    final symbol = currencySymbol ?? defaultCurrencySymbol;
    return 'Save $symbol${discountAmount.toStringAsFixed(2)}';
  }

  /// Parse price string to double
  /// Example: parsePrice("\$99.50") -> 99.5
  /// Handles: "\$99.50", "$99.50", "99.50", "99"
  static double parsePrice(String priceString) {
    // Remove currency symbol and whitespace
    final cleanedPrice = priceString
        .replaceAll('\$', '')
        .replaceAll('USD', '')
        .replaceAll('EUR', '')
        .trim();

    try {
      return double.parse(cleanedPrice);
    } catch (e) {
      throw FormatException('Invalid price format: $priceString');
    }
  }

  /// Check if price is valid (non-negative)
  static bool isValidPrice(double price) {
    return price >= 0 && !price.isNaN && !price.isInfinite;
  }

  /// Round price to nearest cent
  static double roundPrice(double price) {
    return (price * 100).round() / 100;
  }

  /// Format tax amount
  /// Example: formatTax(10) -> "\$10.00 (Tax)"
  static String formatTax(double taxAmount, {String? currencySymbol}) {
    final symbol = currencySymbol ?? defaultCurrencySymbol;
    return '${formatPrice(taxAmount, currencySymbol: symbol)} (Tax)';
  }

  /// Format shipping cost
  /// Example: formatShipping(0) -> "FREE", formatShipping(10) -> "\$10.00"
  static String formatShipping(double shippingCost, {String? currencySymbol}) {
    if (shippingCost == 0) {
      return 'FREE';
    }
    return formatPrice(shippingCost, currencySymbol: currencySymbol);
  }

  /// Format total with all components
  /// Example output: "Subtotal: \$100.00\nTax: \$10.00\nShipping: \$5.00\nTotal: \$115.00"
  static String formatOrderSummary({
    required double subtotal,
    double discount = 0,
    required double tax,
    required double shipping,
    required double total,
    String? currencySymbol,
    required double discountAmount,
    required double taxAmount,
  }) {
    final symbol = currencySymbol ?? defaultCurrencySymbol;

    final buffer = StringBuffer();
    buffer
        .writeln('Subtotal: ${formatPrice(subtotal, currencySymbol: symbol)}');

    if (discount > 0) {
      buffer.writeln(
          'Discount: -${formatPrice(discount, currencySymbol: symbol)}');
    }

    buffer.writeln('Tax: ${formatPrice(tax, currencySymbol: symbol)}');
    buffer.writeln(
        'Shipping: ${formatShipping(shipping, currencySymbol: symbol)}');
    buffer.write('Total: ${formatPrice(total, currencySymbol: symbol)}');

    return buffer.toString();
  }

  /// Format savings percentage
  /// Example: formatSavingsPercent(15) -> "Save 15%"
  static String formatSavingsPercent(double savingsPercent) {
    return 'Save ${savingsPercent.toStringAsFixed(0)}%';
  }

  /// Format price with savings badge
  /// Example: "\$99.50 (Save 20%)" or "\$99.50 (Save \$20.00)"
  static String formatPriceWithSavings(
    double originalPrice,
    double discountedPrice, {
    bool isPercentage = true,
    String? currencySymbol,
  }) {
    final symbol = currencySymbol ?? defaultCurrencySymbol;
    final discountedPriceStr =
        formatPrice(discountedPrice, currencySymbol: symbol);

    if (isPercentage) {
      final percent = ((originalPrice - discountedPrice) / originalPrice * 100);
      return '$discountedPriceStr (Save ${percent.toStringAsFixed(0)}%)';
    } else {
      final savings = originalPrice - discountedPrice;
      return '$discountedPriceStr (Save $symbol${savings.toStringAsFixed(2)})';
    }
  }

  /// Split price into integer and decimal parts for display
  /// Example: splitPrice(99.50) -> {'int': '99', 'decimal': '50'}
  static Map<String, String> splitPrice(double price) {
    final priceStr = price.toStringAsFixed(2);
    final parts = priceStr.split('.');

    return {
      'integer': parts[0],
      'decimal': parts.length > 1 ? parts[1] : '00',
    };
  }

  /// Format price with thousands separator
  /// Example: 1234.56 -> "\$1,234.56"
  static String formatPriceWithThousands(double price,
      {String? currencySymbol}) {
    final symbol = currencySymbol ?? defaultCurrencySymbol;
    final formatter = NumberFormatter();
    return '$symbol${formatter.formatWithThousands(price)}';
  }
}

/// Helper class for number formatting
class NumberFormatter {
  /// Format number with thousands separator
  /// Example: formatWithThousands(1234567.89) -> "1,234,567.89"
  String formatWithThousands(double number) {
    final parts = number.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    // Add thousands separators
    final buffer = StringBuffer();
    int count = 0;

    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
      count++;
    }

    // Reverse and add decimal part
    final result = buffer.toString().split('').reversed.join('');
    return '$result.$decimalPart';
  }
}
