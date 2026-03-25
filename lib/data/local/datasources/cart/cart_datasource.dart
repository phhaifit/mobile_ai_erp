import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';

/// Abstract data source for cart operations
/// Defines contract for local/remote cart data operations
abstract class CartDataSource {
  /// Get cart for specific user
  /// Returns empty cart if user never had a cart
  Future<Cart> getCart(String userId);

  /// Save cart to local storage
  Future<void> saveCart(Cart cart);

  /// Add item to cart
  /// If item with same customization exists, quantity should be incremented
  Future<void> addItemToCart(String userId, CartItem item);

  /// Remove item from cart by ID
  Future<void> removeItemFromCart(String userId, String itemId);

  /// Update quantity of specific cart item
  Future<void> updateItemQuantity(
    String userId,
    String itemId,
    int newQuantity,
  );

  /// Clear all items from cart
  Future<void> clearCart(String userId);

  /// Apply coupon code to cart
  /// Validates coupon before applying
  Future<void> applyCoupon(String userId, String couponCode);

  /// Remove coupon from cart
  Future<void> removeCoupon(String userId);

  /// Get list of available coupons/promotions
  /// Can be filtered by userId for personalized offers
  Future<List<Coupon>> getAvailableCoupons({String? userId});

  /// Validate if coupon code is valid and can be applied
  Future<bool> validateCoupon(String couponCode);

  /// Get specific coupon by code
  Future<Coupon?> getCouponByCode(String couponCode);

  /// Save wishlist for user
  Future<void> saveWishlist(String userId, List<WishlistItem> items);

  /// Get wishlist items for user
  Future<List<WishlistItem>> getWishlist(String userId);

  /// Add item to wishlist
  Future<void> addToWishlist(String userId, WishlistItem item);

  /// Remove item from wishlist
  Future<void> removeFromWishlist(String userId, String variantId);

  /// Clear all wishlist items
  Future<void> clearWishlist(String userId);

  /// Check if product is in wishlist
  Future<bool> isInWishlist(String userId, String variantId);

  /// Get cart history/abandoned carts for user
  /// Used for abandoned cart reminders
  Future<List<Cart>> getCartHistory(String userId, {int limit = 10});

  /// Mark cart as abandoned
  /// Called when cart hasn't been modified for 24 hours
  Future<void> markCartAsAbandoned(String userId);

  /// Get all abandoned carts (for analytics)
  /// Used by backend for abandoned cart reminder emails
  Future<List<Cart>> getAbandonedCarts({int hoursThreshold = 24});

  /// Sync cart from server (when integrated with backend)
  /// For now, mock implementation just simulates delay
  Future<void> syncCartWithServer(String userId);

  /// Migrate guest cart to user cart after login
  Future<void> migrateGuestCartToUser(String guestCartId, String userId);
}
