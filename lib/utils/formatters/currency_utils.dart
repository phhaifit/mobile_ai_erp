class CurrencyUtils {
  /// Formats a double into a localized currency string using Regex.
  static String format(double amount, {String currencyCode = 'VND'}) {
    // Determine decimal places (VND and JPY traditionally have 0)
    int decimals = (currencyCode == 'VND' || currencyCode == 'JPY') ? 0 : 2;
    String fixedAmount = amount.toStringAsFixed(decimals);

    // Split into integer and decimal parts
    List<String> parts = fixedAmount.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? ',${parts[1]}' : ''; // Using comma for decimals in VND/EUR if needed

    // Apply Regex for thousands separators
    // Using '.' as separator for VND/EUR, and ',' for USD
    String separator = (currencyCode == 'USD') ? ',' : '.';
    RegExp regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
    integerPart = integerPart.replaceAll(regex, separator);

    String formattedNumber = '$integerPart$decimalPart';

    // Append the correct symbol
    switch (currencyCode.toUpperCase()) {
      case 'VND':
        return '$formattedNumber ₫';
      case 'USD':
        // USD traditionally uses a period for decimals
        if (parts.length > 1) {
          formattedNumber = '$integerPart.${parts[1]}'; 
        }
        return '\$$formattedNumber';
      case 'EUR':
        return '$formattedNumber €';
      default:
        return '$formattedNumber $currencyCode';
    }
  }
}