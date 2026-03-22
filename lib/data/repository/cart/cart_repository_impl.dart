import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';
import 'package:mobile_ai_erp/data/local/datasources/cart/cart_datasource.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';

/// Implementation of CartRepository using CartDataSource
/// This layer adds business logic and orchestration on top of data source
class CartRepositoryImpl implements CartRepository {
  final CartDataSource _dataSource;

  CartRepositoryImpl({required CartDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Cart> getCart(String userId) async {
    return await _dataSource.getCart(userId);
  }

  @override
  Future<void> saveCart(Cart cart) async {
    return await _dataSource.saveCart(cart);
  }

  @override
  Future<void> addItemToCart(String userId, CartItem item) async {
    return await _dataSource.addItemToCart(userId, item);
  }

  @override
  Future<void> addMultipleItemsToCart(
      String userId, List<CartItem> items) async {
    // Add items one by one (or could be optimized)
    for (final item in items) {
      await _dataSource.addItemToCart(userId, item);
    }
  }

  @override
  Future<void> removeItemFromCart(String userId, String itemId) async {
    return await _dataSource.removeItemFromCart(userId, itemId);
  }

  @override
  Future<void> removeMultipleItemsFromCart(
      String userId, List<String> itemIds) async {
    for (final itemId in itemIds) {
      try {
        await _dataSource.removeItemFromCart(userId, itemId);
      } catch (e) {
        // Continue removing other items even if one fails
        continue;
      }
    }
  }

  @override
  Future<void> updateItemQuantity(
      String userId, String itemId, int newQuantity) async {
    return await _dataSource.updateItemQuantity(userId, itemId, newQuantity);
  }

  @override
  Future<void> clearCart(String userId) async {
    return await _dataSource.clearCart(userId);
  }

  @override
  Future<double> getCartTotal(String userId) async {
    final cart = await getCart(userId);
    return cart.total;
  }

  @override
  Future<void> applyCoupon(String userId, String couponCode) async {
    // Validate coupon exists and is active
    final coupon = await _dataSource.getCouponByCode(couponCode);
    if (coupon == null) {
      throw Exception('Coupon not found: $couponCode');
    }

    // Validate coupon is valid
    if (!coupon.isValid) {
      throw Exception('Coupon is invalid or expired: $couponCode');
    }

    // Get current cart
    final cart = await getCart(userId);

    // Check minimum cart value
    if (coupon.minCartValue != null && cart.subtotal < coupon.minCartValue!) {
      throw Exception(
        'Coupon requires minimum cart value of \$${coupon.minCartValue}. Current: \$${cart.subtotal.toStringAsFixed(2)}',
      );
    }

    return await _dataSource.applyCoupon(userId, couponCode);
  }

  @override
  Future<void> removeCoupon(String userId) async {
    return await _dataSource.removeCoupon(userId);
  }

  @override
  Future<List<Coupon>> getAvailableCoupons({String? userId}) async {
    return await _dataSource.getAvailableCoupons(userId: userId);
  }

  @override
  Future<bool> validateCoupon(String couponCode, double cartValue) async {
    try {
      final isValid = await _dataSource.validateCoupon(couponCode);
      if (!isValid) return false;

      // Check minimum value if applicable
      final coupon = await _dataSource.getCouponByCode(couponCode);
      if (coupon == null) return false;

      if (coupon.minCartValue != null && cartValue < coupon.minCartValue!) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Coupon?> getCouponByCode(String couponCode) async {
    return await _dataSource.getCouponByCode(couponCode);
  }

  @override
  Future<void> saveWishlist(String userId, List<WishlistItem> items) async {
    return await _dataSource.saveWishlist(userId, items);
  }

  @override
  Future<List<WishlistItem>> getWishlist(String userId) async {
    return await _dataSource.getWishlist(userId);
  }

  @override
  Future<void> addToWishlist(String userId, WishlistItem item) async {
    return await _dataSource.addToWishlist(userId, item);
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) async {
    return await _dataSource.removeFromWishlist(userId, productId);
  }

  @override
  Future<void> removeMultipleFromWishlist(
      String userId, List<String> productIds) async {
    for (final productId in productIds) {
      try {
        await _dataSource.removeFromWishlist(userId, productId);
      } catch (e) {
        continue;
      }
    }
  }

  @override
  Future<void> clearWishlist(String userId) async {
    return await _dataSource.clearWishlist(userId);
  }

  @override
  Future<bool> isInWishlist(String userId, String productId) async {
    return await _dataSource.isInWishlist(userId, productId);
  }

  @override
  Future<void> moveWishlistToCart(String userId) async {
    // Get wishlist
    final wishlistItems = await getWishlist(userId);

    if (wishlistItems.isEmpty) return;

    // Convert wishlist items to cart items
    final cartItems = wishlistItems.map((wish) {
      return CartItem(
        id: 'item_${wish.productId}_${DateTime.now().millisecondsSinceEpoch}',
        productId: wish.productId,
        productName: wish.productName,
        unitPrice: wish.effectivePrice,
        quantity: 1,
        imageUrl: wish.imageUrl,
        stockAvailable: wish.stockAvailable,
        category: wish.category,
        dateAdded: DateTime.now(),
      );
    }).toList();

    // Add all to cart
    await addMultipleItemsToCart(userId, cartItems);

    // Clear wishlist
    await clearWishlist(userId);
  }

  @override
  Future<void> moveWishlistItemToCart(String userId, String productId) async {
    // Get wishlist
    final wishlistItems = await getWishlist(userId);

    // Find item
    final wishItem = wishlistItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => throw Exception('Item not in wishlist'),
    );

    // Convert to cart item
    final cartItem = CartItem(
      id: 'item_${wishItem.productId}_${DateTime.now().millisecondsSinceEpoch}',
      productId: wishItem.productId,
      productName: wishItem.productName,
      unitPrice: wishItem.effectivePrice,
      quantity: 1,
      imageUrl: wishItem.imageUrl,
      stockAvailable: wishItem.stockAvailable,
      category: wishItem.category,
      dateAdded: DateTime.now(),
    );

    // Add to cart
    await addItemToCart(userId, cartItem);

    // Remove from wishlist
    await removeFromWishlist(userId, productId);
  }

  @override
  Future<List<Cart>> getCartHistory(String userId, {int limit = 10}) async {
    return await _dataSource.getCartHistory(userId, limit: limit);
  }

  @override
  Future<int> getCartCount(String userId) async {
    final history = await getCartHistory(userId, limit: 1000);
    return history.length;
  }

  @override
  Future<void> markCartAsAbandoned(String userId) async {
    return await _dataSource.markCartAsAbandoned(userId);
  }

  @override
  Future<List<Cart>> getAbandonedCarts({int hoursThreshold = 24}) async {
    return await _dataSource.getAbandonedCarts(hoursThreshold: hoursThreshold);
  }

  @override
  Future<List<String>> validateCartForCheckout(String userId) async {
    final cart = await getCart(userId);
    return cart.validate();
  }

  @override
  Future<void> syncCartWithServer(String userId) async {
    return await _dataSource.syncCartWithServer(userId);
  }

  @override
  Future<void> migrateGuestCartToUser(String guestCartId, String userId) async {
    return await _dataSource.migrateGuestCartToUser(guestCartId, userId);
  }

  @override
  Future<Map<String, dynamic>> getCartStatistics(String userId) async {
    final cart = await getCart(userId);

    // Calculate average item price
    double avgPrice = 0;
    if (cart.items.isNotEmpty) {
      final totalPrice =
          cart.items.fold<double>(0, (sum, item) => sum + item.unitPrice);
      avgPrice = totalPrice / cart.items.length;
    }

    return {
      'itemCount': cart.itemCount,
      'uniqueItems': cart.uniqueItemCount,
      'cartValue': cart.total,
      'subtotal': cart.subtotal,
      'discount': cart.cartLevelDiscount,
      'tax': cart.taxAmount,
      'shipping': cart.shippingAmount,
      'averageItemPrice': avgPrice,
      'savings': cart.savingsAmount,
      'savingsPercentage': cart.savingsPercentage,
      'hasCoupon': cart.hasCoupon,
      'couponCode': cart.appliedCoupon?.code,
    };
  }

  @override
  Future<bool> hasLowStockItems(String userId) async {
    final cart = await getCart(userId);
    return cart.hasLowStockItems;
  }

  @override
  Future<List<CartItem>> getLowStockItems(String userId) async {
    final cart = await getCart(userId);
    return cart.lowStockItems;
  }

  @override
  Future<void> validateCartStock(String userId) async {
    final cart = await getCart(userId);

    // Check if any items are out of stock
    final outOfStockItems = cart.outOfStockItems;
    if (outOfStockItems.isNotEmpty) {
      final itemNames =
          outOfStockItems.map((item) => item.productName).join(', ');
      throw Exception('The following items are out of stock: $itemNames');
    }

    // Optionally check server for updated stock (in real app)
    // For mock, this just validates locally
  }
}
