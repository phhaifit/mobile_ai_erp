import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_calculation.dart';

abstract class CartRepository {
  Future<Cart> getCart();

  Future<Map<String, dynamic>> getCartSummary();

  Future<Cart> addCartItem({required String productId, required int quantity});

  Future<Cart> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  });

  Future<void> removeCartItem({required String itemId});

  Future<CartCalculation> calculateCart({
    required List<String> selectedItemIds,
    String? couponCode,
  });

  Future<Cart> mergeCart({required List<Map<String, dynamic>> items});
}
