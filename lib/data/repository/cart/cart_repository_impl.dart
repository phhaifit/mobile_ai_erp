import 'package:mobile_ai_erp/data/local/datasources/cart/cart_datasource.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import './cart_external_mock_service.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';

/// Implementation of CartRepository using CartDataSource
/// This layer adds business logic and orchestration on top of data source
class CartRepositoryImpl implements CartRepository {
  final CartDataSource _dataSource;
  final CartExternalMockService _externalMockService;

  CartRepositoryImpl({
    required CartDataSource dataSource,
    CartExternalMockService? externalMockService,
  })  : _dataSource = dataSource,
        _externalMockService = externalMockService ?? CartExternalMockService();

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
    String userId,
    List<CartItem> items,
  ) async {
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
    String userId,
    List<String> itemIds,
  ) async {
    for (final itemId in itemIds) {
      try {
        await _dataSource.removeItemFromCart(userId, itemId);
      } catch (_) {
        continue;
      }
    }
  }

  @override
  Future<void> updateItemQuantity(
    String userId,
    String itemId,
    int newQuantity,
  ) async {
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
    final coupon = await validateCoupon(couponCode);

    final cart = await getCart(userId);

    if (coupon.minCartValue != null && cart.subtotal < coupon.minCartValue!) {
      throw Exception(
        'Coupon requires minimum cart value of \$${coupon.minCartValue}. '
        'Current: \$${cart.subtotal.toStringAsFixed(2)}',
      );
    }

    final updatedCart = cart.copyWith(
      appliedCoupon: coupon,
    );

    await _dataSource.saveCart(updatedCart);
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
  Future<Coupon> validateCoupon(String code) async {
    final coupon = await _externalMockService.validateCoupon(code);
    if (!coupon.isValid) {
      throw Exception('Coupon is invalid or expired: $code');
    }
    return coupon;
  }

  @override
  Future<Coupon?> getCouponByCode(String couponCode) async {
    try {
      return await validateCoupon(couponCode);
    } catch (_) {
      return await _dataSource.getCouponByCode(couponCode);
    }
  }

  @override
  Future<int> getRealtimeStock(String variantId) async {
    return await _externalMockService.getRealtimeStock(variantId);
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
    String userId,
    List<String> productIds,
  ) async {
    for (final productId in productIds) {
      try {
        await _dataSource.removeFromWishlist(userId, productId);
      } catch (_) {
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
    final wishlistItems = await getWishlist(userId);

    if (wishlistItems.isEmpty) return;

    final cartItems = wishlistItems.map((wish) {
      final fallbackVariantId = 'variant_${wish.productId}';
      final fallbackSku = 'SKU_${wish.productId}';

      return CartItem(
        id: 'item_${wish.productId}_${DateTime.now().millisecondsSinceEpoch}',
        productId: wish.productId,
        productName: wish.productName,
        imageUrl: wish.imageUrl,
        variantId: fallbackVariantId,
        sku: fallbackSku,
        selectedSize: null,
        selectedColorName: null,
        selectedColorValue: null,
        price: wish.effectivePrice,
        salePrice: null,
        stockAvailable: wish.stockAvailable,
        quantity: 1,
        dateAdded: DateTime.now(),
      );
    }).toList();

    await addMultipleItemsToCart(userId, cartItems);
    await clearWishlist(userId);
  }

  @override
  Future<void> moveWishlistItemToCart(String userId, String productId) async {
    final wishlistItems = await getWishlist(userId);

    final wishItem = wishlistItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => throw Exception('Item not in wishlist'),
    );

    final cartItem = CartItem(
      id: 'item_${wishItem.productId}_${DateTime.now().millisecondsSinceEpoch}',
      productId: wishItem.productId,
      productName: wishItem.productName,
      imageUrl: wishItem.imageUrl,
      variantId: 'variant_${wishItem.productId}',
      sku: 'SKU_${wishItem.productId}',
      selectedSize: null,
      selectedColorName: null,
      selectedColorValue: null,
      price: wishItem.effectivePrice,
      salePrice: null,
      stockAvailable: wishItem.stockAvailable,
      quantity: 1,
      dateAdded: DateTime.now(),
    );

    await addItemToCart(userId, cartItem);
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

    double avgPrice = 0;
    if (cart.items.isNotEmpty) {
      final totalPrice = cart.items.fold<double>(
        0,
        (sum, item) => sum + item.effectivePrice,
      );
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

    if (cart.items.isEmpty) return;

    final outOfStockNames = <String>[];
    final insufficientStockMessages = <String>[];

    for (final item in cart.items) {
      final realtimeStock = await getRealtimeStock(item.variantId);

      if (realtimeStock <= 0) {
        outOfStockNames.add(item.productName);
        continue;
      }

      if (item.quantity > realtimeStock) {
        insufficientStockMessages.add(
          '${item.productName} (requested: ${item.quantity}, available: $realtimeStock)',
        );
      }
    }

    if (outOfStockNames.isNotEmpty) {
      throw Exception(
        'The following items are out of stock: ${outOfStockNames.join(', ')}',
      );
    }

    if (insufficientStockMessages.isNotEmpty) {
      throw Exception(
        'Some items exceed realtime stock: ${insufficientStockMessages.join('; ')}',
      );
    }
  }
}
