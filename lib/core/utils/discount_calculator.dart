import 'package:mobile_ai_erp/domain/entity/cart/coupon.dart';

/// Utility class for calculating discounts and applying promotions
class DiscountCalculator {
  /// Calculate percentage discount amount
  /// Example: calculatePercentageDiscount(100, 20) -> 20 (20% of 100)
  static double calculatePercentageDiscount(double amount, double percent) {
    if (percent < 0 || percent > 100) {
      throw ArgumentError('Discount percentage must be between 0 and 100');
    }
    return (amount * percent) / 100;
  }

  /// Calculate fixed amount discount
  /// Example: calculateFixedDiscount(100, 20) -> 20 (fixed $20 off)
  static num calculateFixedDiscount(double amount, double discountAmount) {
    final discount = discountAmount.clamp(0, amount); // Can't exceed amount
    return discount;
  }

  /// Calculate tiered discount based on quantity
  /// Example: Buy 1-5: no discount, Buy 6-10: 10%, Buy 11+: 20%
  static double calculateTieredDiscount(double unitPrice, int quantity) {
    if (quantity < 6) {
      return 0; // No discount
    } else if (quantity < 11) {
      return 10; // 10% discount
    } else {
      return 20; // 20% discount
    }
  }

  /// Calculate buy X get Y discount
  /// Example: Buy 2 Get 1 Free on $50 items = $50 discount (1 free item)
  static double calculateBOGO(
      double unitPrice, int quantity, int buyQty, int freeQty) {
    final sets = quantity ~/ (buyQty + freeQty);
    final freeItems = sets * freeQty;
    return unitPrice * freeItems;
  }

  /// Calculate volume discount - better price per unit with higher quantity
  /// volumeBreaks: [(5, 10%), (10, 15%), (20, 25%)]
  static double calculateVolumeDiscount(
    double unitPrice,
    int quantity,
    List<(int, double)> volumeBreaks,
  ) {
    double discountPercent = 0;

    // Find applicable discount
    for (final (breakQty, discount) in volumeBreaks) {
      if (quantity >= breakQty) {
        discountPercent = discount;
      } else {
        break;
      }
    }

    return calculatePercentageDiscount(unitPrice * quantity, discountPercent);
  }

  /// Calculate final price after discount
  static double calculateFinalPrice(
      double originalPrice, double discountAmount) {
    return (originalPrice - discountAmount).clamp(0, originalPrice);
  }

  /// Calculate savings percentage
  /// Example: originalPrice=100, finalPrice=80 -> 20%
  static double calculateSavingsPercent(
      double originalPrice, double finalPrice) {
    if (originalPrice == 0) return 0;
    return ((originalPrice - finalPrice) / originalPrice) * 100;
  }

  /// Calculate coupon discount (handles both % and fixed)
  static double calculateCouponDiscount(
    double cartValue,
    Coupon coupon, {
    double? maxDiscount,
  }) {
    double discount;

    try {
      discount = coupon.calculateDiscount(cartValue);
    } catch (e) {
      return 0; // Invalid coupon, no discount
    }

    // Apply global max discount cap if specified
    if (maxDiscount != null && discount > maxDiscount) {
      discount = maxDiscount;
    }

    return discount;
  }

  /// Calculate multiple discounts (stacking)
  /// Example: Apply 10% coupon + 5% loyalty = both applied
  static double calculateStackedDiscounts(
    double amount,
    List<double> discountPercents,
  ) {
    double remaining = amount;

    for (final percent in discountPercents) {
      final discount = calculatePercentageDiscount(remaining, percent);
      remaining -= discount;
    }

    return amount - remaining;
  }

  /// Calculate best discount from multiple options
  /// Returns the discount that gives the customer best savings
  static double calculateBestDiscount(
    double amount,
    List<double> discountOptions,
  ) {
    double maxDiscount = 0;

    for (final discount in discountOptions) {
      if (discount > maxDiscount) {
        maxDiscount = discount;
      }
    }

    return maxDiscount;
  }

  /// Calculate breakeven point for discount
  /// Example: Item costs $50 to produce, sell for $100
  /// With 40% discount = $60 selling price (still profitable)
  static bool isDiscountProfitable(
    double costPrice,
    double sellingPrice,
    double discountPercent,
  ) {
    final discountAmount =
        calculatePercentageDiscount(sellingPrice, discountPercent);
    final finalPrice = calculateFinalPrice(sellingPrice, discountAmount);
    return finalPrice >= costPrice;
  }

  /// Calculate ROI on discount promotion
  /// Example: Discount $100 hoping to sell 10 more units at $50 = $400 gain
  static double calculateDiscountROI(
    double discountCost,
    double additionalRevenue,
  ) {
    if (discountCost == 0) return 0;
    return ((additionalRevenue - discountCost) / discountCost) * 100;
  }

  /// Calculate time-limited discount progression
  /// Example: Flash sale that gets better over time (1st hour: 10%, 2nd hour: 15%)
  static double calculateTimeBasedDiscount(
    DateTime startTime,
    List<(Duration, double)> discountProgression,
  ) {
    final elapsed = DateTime.now().difference(startTime);

    for (final (duration, discount) in discountProgression) {
      if (elapsed < duration) {
        return discount;
      }
    }

    // Return last discount if all time periods passed
    return discountProgression.isNotEmpty ? discountProgression.last.$2 : 0;
  }

  /// Calculate member loyalty discount based on purchase history
  /// loyalty tiers: 0-$100: 5%, $100-$500: 10%, $500+: 15%
  static double calculateLoyaltyDiscount(double totalPurchases) {
    if (totalPurchases >= 500) {
      return 15;
    } else if (totalPurchases >= 100) {
      return 10;
    } else {
      return 5;
    }
  }

  /// Calculate referral discount - both referrer and referee get discount
  static Map<String, double> calculateReferralDiscount(
    double purchaseAmount,
    double referralDiscountPercent,
  ) {
    final discountAmount =
        calculatePercentageDiscount(purchaseAmount, referralDiscountPercent);

    return {
      'referrer': discountAmount,
      'referee': discountAmount,
    };
  }

  /// Calculate seasonal discount multiplier
  /// Example: Holiday season gets 20% base + 5% loyalty = up to 25%
  static double calculateSeasonalMultiplier(String season) {
    return switch (season.toLowerCase()) {
      'holiday' => 1.20,
      'summer' => 1.15,
      'winter' => 1.10,
      'spring' => 1.05,
      _ => 1.0,
    };
  }

  /// Calculate bundle discount - buy multiple items together
  /// Example: Buy 3 items = 5% each, Buy 5 items = 10% each
  static double calculateBundleDiscount(int itemCount) {
    if (itemCount >= 5) {
      return 10;
    } else if (itemCount >= 3) {
      return 5;
    } else if (itemCount >= 2) {
      return 2;
    }
    return 0;
  }

  /// Check if discount threshold is met
  /// Example: Free shipping if cart > $50
  static bool validateDiscountThreshold(double amount, double threshold) {
    return amount >= threshold;
  }

  /// Calculate tax after discount
  /// Important: Tax usually calculated on discounted price (not original)
  static double calculateTaxAfterDiscount(
    double originalPrice,
    double discountAmount,
    double taxPercent,
  ) {
    final discountedPrice = calculateFinalPrice(originalPrice, discountAmount);
    return calculatePercentageDiscount(discountedPrice, taxPercent);
  }

  /// Calculate effective discount rate considering all factors
  /// Useful for price comparison
  static double calculateEffectiveDiscountRate(
    double originalPrice,
    double finalPrice,
  ) {
    if (originalPrice == 0) return 0;
    return ((originalPrice - finalPrice) / originalPrice) * 100;
  }

  /// Generate discount summary
  /// Returns formatted string describing all discounts applied
  static String generateDiscountSummary({
    double? couponDiscount,
    double? loyaltyDiscount,
    double? seasonalDiscount,
    double? bundleDiscount,
    double totalDiscount = 0,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Discount Breakdown:');

    if (couponDiscount != null && couponDiscount > 0) {
      buffer.writeln('  Coupon: -\$${couponDiscount.toStringAsFixed(2)}');
    }

    if (loyaltyDiscount != null && loyaltyDiscount > 0) {
      buffer.writeln('  Loyalty: -\$${loyaltyDiscount.toStringAsFixed(2)}');
    }

    if (seasonalDiscount != null && seasonalDiscount > 0) {
      buffer.writeln('  Seasonal: -\$${seasonalDiscount.toStringAsFixed(2)}');
    }

    if (bundleDiscount != null && bundleDiscount > 0) {
      buffer.writeln('  Bundle: -\$${bundleDiscount.toStringAsFixed(2)}');
    }

    buffer.write('Total Savings: -\$${totalDiscount.toStringAsFixed(2)}');

    return buffer.toString();
  }
}
