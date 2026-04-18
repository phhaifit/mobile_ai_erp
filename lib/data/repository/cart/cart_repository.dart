import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_calculation.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist.dart';

abstract class CartRepository {
  Future<Cart> getCart({required String customerId, required String tenantId});

  Future<Map<String, dynamic>> getCartSummary({
    required String customerId,
    required String tenantId,
  });

  Future<Cart> addCartItem({
    required String customerId,
    required String tenantId,
    required String productId,
    String? variantId,
    required int quantity,
  });

  Future<Cart> updateCartItemQuantity({
    required String customerId,
    required String tenantId,
    required String itemId,
    required int quantity,
  });

  Future<Cart> removeCartItem({
    required String customerId,
    required String tenantId,
    required String itemId,
  });

  Future<CartCalculation> calculateCart({
    required String customerId,
    required String tenantId,
    required List<String> selectedItemIds,
    String? couponCode,
  });

  Future<Cart> mergeCart({
    required String customerId,
    required String tenantId,
    required List<Map<String, dynamic>> items,
  });

  Future<Wishlist> getWishlist({
    required String customerId,
    required String tenantId,
  });

  Future<Map<String, dynamic>> getWishlistSummary({
    required String customerId,
    required String tenantId,
  });

  Future<Wishlist> addToWishlist({
    required String customerId,
    required String tenantId,
    required String productId,
    String? variantId,
  });

  Future<Wishlist> removeFromWishlist({
    required String customerId,
    required String tenantId,
    required String itemId,
  });

  Future<Wishlist> mergeWishlist({
    required String customerId,
    required String tenantId,
    required List<Map<String, dynamic>> items,
  });
}
