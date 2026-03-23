import 'package:mobile_ai_erp/domain/entity/cart/coupon.dart';

/// Temporary mock service for external integrations:
/// - Warehouse team (Epic 4): realtime stock
/// - Marketing team (Epic 17): coupon validation
///
/// Replace this class later with real remote repositories / API clients.
class CartExternalMockService {
  Future<int> getRealtimeStock(String variantId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    const mockStockByVariant = <String, int>{
      'variant_1': 12,
      'variant_2': 4,
      'variant_3': 0,
      'variant_demo_red_m': 8,
      'variant_demo_blue_l': 2,
      'variant_demo_black_xl': 0,
    };

    return mockStockByVariant[variantId] ?? 10;
  }

  Future<Coupon> validateCoupon(String code) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final normalizedCode = code.trim().toUpperCase();

    final mockCoupons = <String, Coupon>{
      'SAVE10': Coupon(
        code: 'SAVE10',
        discountValue: 10,
        isPercentage: true,
        minCartValue: 100,
        description: '10% off for orders from \$100',
        isActive: true,
        expiryDate: DateTime(2026, 12, 31),
      ),
      'FREESHIP': Coupon(
        code: 'FREESHIP',
        discountValue: 30,
        isPercentage: false,
        minCartValue: 200,
        description: '\$30 off shipping-related promotion',
        isActive: true,
        expiryDate: DateTime(2026, 12, 31),
      ),
      'WELCOME20': Coupon(
        code: 'WELCOME20',
        discountValue: 20,
        isPercentage: true,
        minCartValue: 300,
        maxDiscount: 100,
        description: '20% off for first orders, capped at \$100',
        isActive: true,
        expiryDate: DateTime(2026, 12, 31),
      ),
      'EXPIRED50': Coupon(
        code: 'EXPIRED50',
        discountValue: 50,
        isPercentage: true,
        minCartValue: 500,
        description: 'Expired test coupon',
        isActive: true,
        expiryDate: DateTime(2025, 12, 31),
      ),
      'DISABLED15': Coupon(
        code: 'DISABLED15',
        discountValue: 15,
        isPercentage: true,
        description: 'Inactive test coupon',
        isActive: false,
      ),
    };

    final coupon = mockCoupons[normalizedCode];
    if (coupon == null) {
      throw Exception('Coupon not found: $code');
    }

    if (!coupon.isValid) {
      throw Exception('Coupon is invalid or expired: $code');
    }

    return coupon;
  }
}
