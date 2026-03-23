import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';
import 'package:mobile_ai_erp/data/local/datasources/cart/cart_datasource.dart';

/// Mock implementation of CartDataSource
class CartLocalDataSourceImpl implements CartDataSource {
  // In-memory storage for carts (userId -> Cart)
  static final Map<String, Cart> _carts = {};

  // In-memory storage for wishlists (userId -> List<WishlistItem>)
  static final Map<String, List<WishlistItem>> _wishlists = {};

  // Mock available coupons
  List<Coupon> _mockCoupons = [
    Coupon(
      code: 'SUMMER20',
      discountValue: 20,
      isPercentage: true,
      expiryDate: DateTime.now().add(Duration(days: 30)),
      minCartValue: 50,
      description: '20% off summer collection',
      isActive: true,
    ),
    Coupon(
      code: 'SAVE50',
      discountValue: 50,
      isPercentage: false,
      expiryDate: DateTime.now().add(Duration(days: 15)),
      minCartValue: 200,
      maxDiscount: 100,
      description: 'Save \$50 on orders over \$200',
      isActive: true,
    ),
    Coupon(
      code: 'WELCOME10',
      discountValue: 10,
      isPercentage: true,
      minCartValue: 0,
      description: '10% off for new users',
      isActive: true,
    ),
    Coupon(
      code: 'FREESHIP',
      discountValue: 0,
      isPercentage: false,
      description: 'Free shipping (no discount)',
      isActive: true,
    ),
    Coupon(
      code: 'EXPIRED',
      discountValue: 30,
      isPercentage: true,
      expiryDate: DateTime.now().subtract(Duration(days: 5)),
      description: 'This coupon has expired',
      isActive: true,
    ),
  ];

  // Mock products for adding to cart
  final Map<String, dynamic> _mockProducts = {
    'prod_001': {
      'name': 'Wireless Headphones',
      'price': 79.99,
      'image': 'https://via.placeholder.com/150?text=Headphones',
      'stock': 15,
      'category': 'Electronics',
      'sku': 'WH-001',
    },
    'prod_002': {
      'name': 'USB-C Cable',
      'price': 12.99,
      'image': 'https://via.placeholder.com/150?text=Cable',
      'stock': 50,
      'category': 'Accessories',
      'sku': 'UC-002',
    },
    'prod_003': {
      'name': 'Phone Case',
      'price': 24.99,
      'image': 'https://via.placeholder.com/150?text=Case',
      'stock': 3,
      'category': 'Accessories',
      'sku': 'PC-003',
    },
    'prod_004': {
      'name': 'Screen Protector',
      'price': 9.99,
      'image': 'https://via.placeholder.com/150?text=Protector',
      'stock': 0,
      'category': 'Accessories',
      'sku': 'SP-004',
    },
    'prod_005': {
      'name': 'Portable Charger',
      'price': 49.99,
      'image': 'https://via.placeholder.com/150?text=Charger',
      'stock': 25,
      'category': 'Electronics',
      'sku': 'PC-005',
    },
  };

  /// Simulate network delay
  Future<void> _simulateDelay({int milliseconds = 500}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  @override
  Future<Cart> getCart(String userId) async {
    final cart = _carts[userId] ??
        Cart(
          id: 'cart_$userId',
          userId: userId,
          items: [],
          dateCreated: DateTime.now(),
          dateModified: DateTime.now(),
        );

    return cart;
  }

  @override
  Future<void> saveCart(Cart cart) async {
    await _simulateDelay(milliseconds: 300);
    _carts[cart.userId] = cart;
  }

  @override
  Future<void> addItemToCart(String userId, CartItem item) async {
    final cart = await getCart(userId);

    final updatedCart = cart.addItem(item);

    await saveCart(updatedCart);
  }

  @override
  Future<void> removeItemFromCart(String userId, String itemId) async {
    await _simulateDelay();

    final cart = await getCart(userId);
    final updatedCart = cart.removeItem(itemId);
    await saveCart(updatedCart);
  }

  @override
  Future<void> updateItemQuantity(
      String userId, String itemId, int newQuantity) async {
    await _simulateDelay();

    final cart = await getCart(userId);
    final updatedCart = cart.updateItemQuantity(itemId, newQuantity);
    await saveCart(updatedCart);
  }

  @override
  Future<void> clearCart(String userId) async {
    await _simulateDelay();

    final cart = await getCart(userId);
    final clearedCart = cart.clear();
    await saveCart(clearedCart);
  }

  @override
  Future<void> applyCoupon(String userId, String couponCode) async {
    await _simulateDelay();

    final coupon = await getCouponByCode(couponCode);
    if (coupon == null) {
      throw Exception('Coupon not found: $couponCode');
    }

    final cart = await getCart(userId);
    final updatedCart = cart.applyCoupon(coupon);
    await saveCart(updatedCart);
  }

  @override
  Future<void> removeCoupon(String userId) async {
    await _simulateDelay();

    final cart = await getCart(userId);
    final updatedCart = cart.removeCoupon();
    await saveCart(updatedCart);
  }

  @override
  Future<List<Coupon>> getAvailableCoupons({String? userId}) async {
    await _simulateDelay(milliseconds: 300);

    // Filter only active and non-expired coupons
    return _mockCoupons.where((coupon) => coupon.isValid).toList();
  }

  @override
  Future<bool> validateCoupon(String couponCode) async {
    await _simulateDelay(milliseconds: 200);

    final coupon = _mockCoupons.firstWhere(
      (c) => c.code == couponCode,
      orElse: () => throw Exception('Coupon not found'),
    );

    return coupon.isValid;
  }

  @override
  Future<Coupon?> getCouponByCode(String couponCode) async {
    await _simulateDelay(milliseconds: 150);

    try {
      return _mockCoupons.firstWhere((c) => c.code == couponCode);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveWishlist(String userId, List<WishlistItem> items) async {
    await _simulateDelay();

    _wishlists[userId] = items;
  }

  @override
  Future<List<WishlistItem>> getWishlist(String userId) async {
    await _simulateDelay();

    return _wishlists[userId] ?? [];
  }

  @override
  Future<void> addToWishlist(String userId, WishlistItem item) async {
    await _simulateDelay();

    final wishlist = await getWishlist(userId);

    // Check if item already exists
    final existingIndex =
        wishlist.indexWhere((w) => w.productId == item.productId);

    if (existingIndex != -1) {
      // Update existing
      wishlist[existingIndex] = item.copyWith(lastViewed: DateTime.now());
    } else {
      // Add new
      wishlist.add(item);
    }

    await saveWishlist(userId, wishlist);
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) async {
    await _simulateDelay();

    final wishlist = await getWishlist(userId);
    wishlist.removeWhere((item) => item.productId == productId);
    await saveWishlist(userId, wishlist);
  }

  @override
  Future<void> clearWishlist(String userId) async {
    await _simulateDelay();

    _wishlists[userId] = [];
  }

  @override
  Future<bool> isInWishlist(String userId, String productId) async {
    await _simulateDelay(milliseconds: 100);

    final wishlist = await getWishlist(userId);
    return wishlist.any((item) => item.productId == productId);
  }

  @override
  Future<List<Cart>> getCartHistory(String userId, {int limit = 10}) async {
    await _simulateDelay();

    // For mock, return only current cart if exists
    if (_carts.containsKey(userId)) {
      return [_carts[userId]!];
    }
    return [];
  }

  @override
  Future<void> markCartAsAbandoned(String userId) async {
    await _simulateDelay();

    final cart = await getCart(userId);
    if (cart.items.isNotEmpty) {
      final abandonedCart = cart.copyWith(
        isAbandoned: true,
        abandonedDate: DateTime.now(),
        status: 'abandoned',
      );
      await saveCart(abandonedCart);
    }
  }

  @override
  Future<List<Cart>> getAbandonedCarts({int hoursThreshold = 24}) async {
    await _simulateDelay();

    final now = DateTime.now();
    final threshold = Duration(hours: hoursThreshold);

    final abandonedCarts = _carts.values.where((cart) {
      if (cart.isAbandoned) {
        return true;
      }

      // Check if cart hasn't been modified for threshold
      final timeSinceModified = now.difference(cart.dateModified);
      return timeSinceModified.compareTo(threshold) >= 0;
    }).toList();

    return abandonedCarts;
  }

  @override
  Future<void> syncCartWithServer(String userId) async {
    // Simulate sync delay
    await _simulateDelay(milliseconds: 800);

    // In mock implementation, just update sync timestamp
    final cart = await getCart(userId);
    final syncedCart = cart.copyWith(dateSynced: DateTime.now());
    await saveCart(syncedCart);
  }

  @override
  Future<void> migrateGuestCartToUser(String guestCartId, String userId) async {
    await _simulateDelay();

    // Get guest cart
    final guestCart = _carts[guestCartId];
    if (guestCart == null) return;

    // Get user cart
    final userCart = await getCart(userId);

    // Merge items (guest items + user items)
    final mergedItems = [...userCart.items, ...guestCart.items];

    // Create merged cart
    final mergedCart = userCart.copyWith(
      items: mergedItems,
      appliedCoupon: userCart.appliedCoupon ?? guestCart.appliedCoupon,
    );

    // Save to user
    await saveCart(mergedCart);

    // Clean up guest cart
    _carts.remove(guestCartId);
  }

  /// Helper: Create mock cart item from product data
  CartItem _createMockCartItem(String productId) {
    final product = _mockProducts[productId];
    if (product == null) {
      throw Exception('Product not found: $productId');
    }

    return CartItem(
      id: 'item_${productId}_${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      productName: product['name'],
      imageUrl: product['image'],
      variantId: product['variantId'] ?? 'variant_$productId',
      sku: product['sku'] ?? '',
      selectedSize: product['size'],
      selectedColorName: product['colorName'],
      selectedColorValue: product['colorValue'],
      price: (product['price'] as num).toDouble(),
      salePrice: product['salePrice'] != null
          ? (product['salePrice'] as num).toDouble()
          : null,
      stockAvailable: product['stock'],
      quantity: 1,
      dateAdded: DateTime.now(),
    );
  }

  /// Helper: Get mock available products
  List<dynamic> getMockProducts() {
    return _mockProducts.values.toList();
  }

  /// Helper: Create sample filled cart for demo/testing
  Future<Cart> createSampleCart(String userId) async {
    // Create cart with sample items
    var cart = Cart(
      id: 'cart_$userId',
      userId: userId,
      dateCreated: DateTime.now(),
      dateModified: DateTime.now(),
    );

    // Add sample items
    cart = cart.addItem(_createMockCartItem('prod_001'));
    cart = cart.addItem(_createMockCartItem('prod_002'));
    cart = cart.addItem(_createMockCartItem('prod_005'));

    await saveCart(cart);
    return cart;
  }
}
