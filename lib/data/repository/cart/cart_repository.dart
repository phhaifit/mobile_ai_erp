import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';

/// Abstract repository for cart business operations
/// Provides clean API for domain layer and can abstract multiple data sources
abstract class CartRepository {
  /// Get cart for specific user
  /// Returns empty cart if user never had a cart
  Future<Cart> getCart(String userId);

  /// Save cart to persistent storage
  Future<void> saveCart(Cart cart);

  /// Add item to cart
  /// Automatically increments quantity if item with same variant exists
  /// Throws [InsufficientStockException] if quantity exceeds stock
  Future<void> addItemToCart(String userId, CartItem item);

  /// Add multiple items to cart (bulk operation)
  Future<void> addMultipleItemsToCart(String userId, List<CartItem> items);

  /// Remove item from cart by ID
  /// Throws [CartItemNotFoundException] if item not found
  Future<void> removeItemFromCart(String userId, String itemId);

  /// Remove multiple items from cart (bulk delete)
  Future<void> removeMultipleItemsFromCart(String userId, List<String> itemIds);

  /// Update quantity of specific cart item
  /// Validates stock before updating
  /// Throws [CartItemNotFoundException] if item not found
  /// Throws [InsufficientStockException] if new quantity exceeds stock
  Future<void> updateItemQuantity(
    String userId,
    String itemId,
    int newQuantity,
  );

  /// Clear all items from cart
  Future<void> clearCart(String userId);

  /// Get current cart total (with discount, tax, shipping)
  /// Useful for real-time price updates
  Future<double> getCartTotal(String userId);

  /// Apply coupon/promotion code to cart
  /// Validates coupon before applying
  Future<void> applyCoupon(String userId, String couponCode);

  /// Remove applied coupon from cart
  Future<void> removeCoupon(String userId);

  /// Get list of available coupons/promotions
  Future<List<Coupon>> getAvailableCoupons({String? userId});

  /// Validate coupon with Marketing service
  /// Mocked for now until Epic 17 is integrated
  Future<Coupon> validateCoupon(String code);

  /// Get coupon details by code
  Future<Coupon?> getCouponByCode(String couponCode);

  /// Get realtime stock from Warehouse service
  /// Mocked for now until Epic 4 is integrated
  Future<int> getRealtimeStock(String variantId);

  /// Save wishlist items for user
  Future<void> saveWishlist(String userId, List<WishlistItem> items);

  /// Get all wishlist items for user
  Future<List<WishlistItem>> getWishlist(String userId);

  /// Add product to wishlist
  Future<void> addToWishlist(String userId, WishlistItem item);

  /// Remove product from wishlist by product ID
  Future<void> removeFromWishlist(String userId, String productId);

  /// Remove multiple items from wishlist
  Future<void> removeMultipleFromWishlist(
    String userId,
    List<String> productIds,
  );

  /// Clear entire wishlist
  Future<void> clearWishlist(String userId);

  /// Check if product is in user's wishlist
  Future<bool> isInWishlist(String userId, String productId);

  /// Move all items from wishlist to cart
  Future<void> moveWishlistToCart(String userId);

  /// Move specific wishlist item to cart
  Future<void> moveWishlistItemToCart(String userId, String productId);

  /// Get cart history for user
  Future<List<Cart>> getCartHistory(String userId, {int limit = 10});

  /// Get total number of carts user has created
  Future<int> getCartCount(String userId);

  /// Mark cart as abandoned
  Future<void> markCartAsAbandoned(String userId);

  /// Get all abandoned carts system-wide
  Future<List<Cart>> getAbandonedCarts({int hoursThreshold = 24});

  /// Validate cart before checkout
  Future<List<String>> validateCartForCheckout(String userId);

  /// Sync cart with remote server
  Future<void> syncCartWithServer(String userId);

  /// Migrate guest cart to logged-in user cart
  Future<void> migrateGuestCartToUser(String guestCartId, String userId);

  /// Get cart statistics for user
  Future<Map<String, dynamic>> getCartStatistics(String userId);

  /// Check if any items in cart have low stock
  Future<bool> hasLowStockItems(String userId);

  /// Get items with low/no stock
  Future<List<CartItem>> getLowStockItems(String userId);

  /// Validate all items in cart have sufficient stock
  Future<void> validateCartStock(String userId);
}
