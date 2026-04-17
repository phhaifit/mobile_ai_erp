import 'package:mobile_ai_erp/data/local/datasources/cart/cart_datasource.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_calculation.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';

class CartLocalDataSourceImpl implements CartDataSource {
  static final Map<String, Cart> _carts = {};
  static final Map<String, Wishlist> _wishlists = {};

  Future<void> _simulateDelay({int milliseconds = 250}) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  String _key({required String customerId, required String tenantId}) {
    return '$tenantId::$customerId';
  }

  List<CartItemAttribute> _attrs(List<Map<String, String>> values) {
    return values
        .map(
          (e) => CartItemAttribute(
            label: e['label'] ?? '',
            value: e['value'] ?? '',
          ),
        )
        .toList();
  }

  List<WishlistItemAttribute> _wishlistAttrs(List<Map<String, String>> values) {
    return values
        .map(
          (e) => WishlistItemAttribute(
            label: e['label'] ?? '',
            value: e['value'] ?? '',
          ),
        )
        .toList();
  }

  Cart _buildDefaultCart({
    required String customerId,
    required String tenantId,
  }) {
    final now = DateTime.now();

    final items = <CartItem>[
      CartItem(
        id: '8f1b0a7d-5f0e-4f7d-9f11-7ecf4f17a001',
        cartId: 'cart_$customerId',
        productId: 'd1a6e0d7-6e7a-4c41-93a2-2c8f9b101111',
        variantId: 'variant-sneaker-42-white',
        quantity: 1,
        unitPrice: '1590000',
        originalPrice: '1890000',
        lineTotal: '1590000',
        addedAt: now.subtract(const Duration(minutes: 10)),
        productName: 'Sneaker Cart Test - 42 / White',
        sku: 'CART-SNEAKER-42',
        productType: 'variant',
        productStatus: 'selling',
        thumbnailUrl:
            'https://cdn.example.com/products/sneaker-42-white-main.jpg',
        variantSummary: '42, White',
        attributes: _attrs([
          {'label': 'Size', 'value': '42'},
          {'label': 'Color', 'value': 'White'},
        ]),
        availableStock: 8,
        isPriceChanged: false,
        isAvailable: true,
        stockWarning: false,
      ),
      CartItem(
        id: '8f1b0a7d-5f0e-4f7d-9f11-7ecf4f17a002',
        cartId: 'cart_$customerId',
        productId: '4f4d74e8-9a9a-4d65-8bd1-13d91a772222',
        variantId: 'variant-tshirt-m-black',
        quantity: 2,
        unitPrice: '249000',
        originalPrice: '299000',
        lineTotal: '498000',
        addedAt: now.subtract(const Duration(minutes: 8)),
        productName: 'Áo thun Oversize Cart Test - M / Black',
        sku: 'CART-TSHIRT-M-BLACK',
        productType: 'variant',
        productStatus: 'selling',
        thumbnailUrl:
            'https://cdn.example.com/products/tshirt-m-black-main.jpg',
        variantSummary: 'M, Black',
        attributes: _attrs([
          {'label': 'Size', 'value': 'M'},
          {'label': 'Color', 'value': 'Black'},
        ]),
        availableStock: 2,
        isPriceChanged: true,
        isAvailable: true,
        stockWarning: true,
      ),
      CartItem(
        id: '8f1b0a7d-5f0e-4f7d-9f11-7ecf4f17a003',
        cartId: 'cart_$customerId',
        productId: '7c8a9d70-cb71-4d67-a57f-6e2a3f113333',
        variantId: null,
        quantity: 1,
        unitPrice: '2391000',
        originalPrice: '2490000',
        lineTotal: '2391000',
        addedAt: now.subtract(const Duration(minutes: 5)),
        productName: 'Logitech MX Master 3S',
        sku: 'CART-MOUSE-MX3S',
        productType: 'standalone',
        productStatus: 'selling',
        thumbnailUrl: 'https://cdn.example.com/products/mx-master-3s-main.jpg',
        variantSummary: null,
        attributes: const [],
        availableStock: 0,
        isPriceChanged: true,
        isAvailable: false,
        stockWarning: true,
      ),
    ];

    return Cart(
      id: '4e6d8a84-8e1f-4f7d-b2e8-6f2d53b2a101',
      tenantId: tenantId,
      customerId: customerId,
      subtotal: '4479000',
      totalItems: 3,
      items: items,
      createdAt: now.subtract(const Duration(minutes: 15)),
      updatedAt: now.subtract(const Duration(minutes: 5)),
    );
  }

  Wishlist _buildDefaultWishlist({
    required String customerId,
    required String tenantId,
  }) {
    final now = DateTime.now();

    final items = <WishlistItem>[
      WishlistItem(
        id: 'c1f8b96a-6f0a-4d9f-9c8c-0d8b7d110001',
        wishlistId: 'wishlist_$customerId',
        productId: 'd1a6e0d7-6e7a-4c41-93a2-2c8f9b101111',
        variantId: 'variant-sneaker-42-white',
        addedAt: now.subtract(const Duration(minutes: 20)),
        productName: 'Sneaker Cart Test - 42 / White',
        sku: 'CART-SNEAKER-42',
        productType: 'variant',
        productStatus: 'selling',
        sellingPrice: '1590000',
        originalPrice: '1890000',
        thumbnailUrl:
            'https://cdn.example.com/products/sneaker-42-white-main.jpg',
        variantSummary: '42, White',
        attributes: _wishlistAttrs([
          {'label': 'Size', 'value': '42'},
          {'label': 'Color', 'value': 'White'},
        ]),
        isAvailable: true,
      ),
      WishlistItem(
        id: 'c1f8b96a-6f0a-4d9f-9c8c-0d8b7d110002',
        wishlistId: 'wishlist_$customerId',
        productId: '4f4d74e8-9a9a-4d65-8bd1-13d91a772222',
        variantId: 'variant-tshirt-m-black',
        addedAt: now.subtract(const Duration(minutes: 18)),
        productName: 'Áo thun Oversize Cart Test - M / Black',
        sku: 'CART-TSHIRT-M-BLACK',
        productType: 'variant',
        productStatus: 'selling',
        sellingPrice: '249000',
        originalPrice: '299000',
        thumbnailUrl:
            'https://cdn.example.com/products/tshirt-m-black-main.jpg',
        variantSummary: 'M, Black',
        attributes: _wishlistAttrs([
          {'label': 'Size', 'value': 'M'},
          {'label': 'Color', 'value': 'Black'},
        ]),
        isAvailable: true,
      ),
      WishlistItem(
        id: 'c1f8b96a-6f0a-4d9f-9c8c-0d8b7d110003',
        wishlistId: 'wishlist_$customerId',
        productId: '7c8a9d70-cb71-4d67-a57f-6e2a3f113333',
        variantId: null,
        addedAt: now.subtract(const Duration(minutes: 15)),
        productName: 'Logitech MX Master 3S',
        sku: 'CART-MOUSE-MX3S',
        productType: 'standalone',
        productStatus: 'out_of_stock',
        sellingPrice: '2290000',
        originalPrice: '2490000',
        thumbnailUrl: 'https://cdn.example.com/products/mx-master-3s-main.jpg',
        variantSummary: null,
        attributes: const [],
        isAvailable: false,
      ),
    ];

    return Wishlist(
      id: '8e6d4f11-2ad8-4d5e-b0e5-2d77d1a8f001',
      tenantId: tenantId,
      customerId: customerId,
      totalItems: 3,
      items: items,
      createdAt: now.subtract(const Duration(minutes: 30)),
      updatedAt: now.subtract(const Duration(minutes: 15)),
    );
  }

  int _sumQuantity(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  String _sumLineTotals(List<CartItem> items) {
    final total = items.fold<int>(
      0,
      (sum, item) => sum + int.parse(item.lineTotal),
    );
    return total.toString();
  }

  @override
  Future<Cart> getCart({
    required String customerId,
    required String tenantId,
  }) async {
    await _simulateDelay();
    final key = _key(customerId: customerId, tenantId: tenantId);
    return _carts.putIfAbsent(
      key,
      () => _buildDefaultCart(customerId: customerId, tenantId: tenantId),
    );
  }

  @override
  Future<Cart> addCartItem({
    required String customerId,
    required String tenantId,
    required String productId,
    String? variantId,
    required int quantity,
  }) async {
    await _simulateDelay();

    final currentCart = await getCart(
      customerId: customerId,
      tenantId: tenantId,
    );
    final now = DateTime.now();

    final existingIndex = currentCart.items.indexWhere(
      (item) => item.productId == productId && item.variantId == variantId,
    );

    final updatedItems = [...currentCart.items];

    if (existingIndex != -1) {
      final existing = updatedItems[existingIndex];
      final newQuantity = existing.quantity + quantity;
      final newLineTotal = (int.parse(existing.unitPrice) * newQuantity)
          .toString();

      updatedItems[existingIndex] = existing.copyWith(
        quantity: newQuantity,
        lineTotal: newLineTotal,
      );
    } else {
      CartItem newItem;

      if (productId == 'd1a6e0d7-6e7a-4c41-93a2-2c8f9b101111') {
        newItem = CartItem(
          id: 'new_${now.microsecondsSinceEpoch}',
          cartId: currentCart.id,
          productId: productId,
          variantId: variantId,
          quantity: quantity,
          unitPrice: '1590000',
          originalPrice: '1890000',
          lineTotal: (1590000 * quantity).toString(),
          addedAt: now,
          productName: 'Sneaker Cart Test - 42 / White',
          sku: 'CART-SNEAKER-42',
          productType: 'variant',
          productStatus: 'selling',
          thumbnailUrl:
              'https://cdn.example.com/products/sneaker-42-white-main.jpg',
          variantSummary: '42, White',
          attributes: _attrs([
            {'label': 'Size', 'value': '42'},
            {'label': 'Color', 'value': 'White'},
          ]),
          availableStock: 8,
          isPriceChanged: false,
          isAvailable: true,
          stockWarning: false,
        );
      } else {
        newItem = CartItem(
          id: 'new_${now.microsecondsSinceEpoch}',
          cartId: currentCart.id,
          productId: productId,
          variantId: variantId,
          quantity: quantity,
          unitPrice: '249000',
          originalPrice: '299000',
          lineTotal: (249000 * quantity).toString(),
          addedAt: now,
          productName: 'Áo thun Oversize Cart Test - M / Black',
          sku: 'CART-TSHIRT-M-BLACK',
          productType: variantId != null ? 'variant' : 'standalone',
          productStatus: 'selling',
          thumbnailUrl:
              'https://cdn.example.com/products/tshirt-m-black-main.jpg',
          variantSummary: variantId != null ? 'M, Black' : null,
          attributes: variantId != null
              ? _attrs([
                  {'label': 'Size', 'value': 'M'},
                  {'label': 'Color', 'value': 'Black'},
                ])
              : const [],
          availableStock: 2,
          isPriceChanged: false,
          isAvailable: true,
          stockWarning: quantity >= 2,
        );
      }

      updatedItems.add(newItem);
    }

    final updatedCart = currentCart.copyWith(
      items: updatedItems,
      totalItems: _sumQuantity(updatedItems),
      subtotal: _sumLineTotals(updatedItems),
      updatedAt: now,
    );

    final key = _key(customerId: customerId, tenantId: tenantId);
    _carts[key] = updatedCart;
    return updatedCart;
  }

  @override
  Future<Cart> updateCartItemQuantity({
    required String customerId,
    required String tenantId,
    required String itemId,
    required int quantity,
  }) async {
    await _simulateDelay();

    final currentCart = await getCart(
      customerId: customerId,
      tenantId: tenantId,
    );
    final updatedItems = currentCart.items.map((item) {
      if (item.id != itemId) return item;
      return item.copyWith(
        quantity: quantity,
        lineTotal: (int.parse(item.unitPrice) * quantity).toString(),
      );
    }).toList();

    final updatedCart = currentCart.copyWith(
      items: updatedItems,
      totalItems: _sumQuantity(updatedItems),
      subtotal: _sumLineTotals(updatedItems),
      updatedAt: DateTime.now(),
    );

    final key = _key(customerId: customerId, tenantId: tenantId);
    _carts[key] = updatedCart;
    return updatedCart;
  }

  @override
  Future<Cart> removeCartItem({
    required String customerId,
    required String tenantId,
    required String itemId,
  }) async {
    await _simulateDelay();

    final currentCart = await getCart(
      customerId: customerId,
      tenantId: tenantId,
    );
    final updatedItems = currentCart.items
        .where((item) => item.id != itemId)
        .toList();

    final updatedCart = currentCart.copyWith(
      items: updatedItems,
      totalItems: _sumQuantity(updatedItems),
      subtotal: _sumLineTotals(updatedItems),
      updatedAt: DateTime.now(),
    );

    final key = _key(customerId: customerId, tenantId: tenantId);
    _carts[key] = updatedCart;
    return updatedCart;
  }

  @override
  Future<CartCalculation> calculateCart({
    required String customerId,
    required String tenantId,
    required List<String> selectedItemIds,
    String? couponCode,
  }) async {
    await _simulateDelay();

    final cart = await getCart(customerId: customerId, tenantId: tenantId);
    final selectedItems = cart.items
        .where((item) => selectedItemIds.contains(item.id))
        .toList();

    final subtotal = selectedItems.fold<int>(
      0,
      (sum, item) => sum + int.parse(item.lineTotal),
    );

    int discount = 0;
    AppliedCoupon? coupon;

    if (couponCode != null && couponCode.trim().isNotEmpty) {
      if (couponCode == 'CART10') {
        discount = (subtotal * 0.1).round();
        coupon = AppliedCoupon(
          code: 'CART10',
          name: 'Giảm 10%',
          isApplied: true,
          isValid: true,
          discountAmount: discount.toString(),
          reason: null,
        );
      } else {
        coupon = AppliedCoupon(
          code: couponCode,
          name: null,
          isApplied: false,
          isValid: false,
          discountAmount: '0',
          reason: 'Coupon không hợp lệ',
        );
      }
    }

    final total = subtotal - discount;
    final selectedQuantity = selectedItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return CartCalculation(
      items: selectedItems,
      summary: CartCalculationSummary(
        subtotal: subtotal.toString(),
        discount: discount.toString(),
        total: total.toString(),
        selectedItemsCount: selectedItems.length,
        selectedQuantity: selectedQuantity,
      ),
      coupon: coupon,
    );
  }

  @override
  Future<Wishlist> getWishlist({
    required String customerId,
    required String tenantId,
  }) async {
    await _simulateDelay();
    final key = _key(customerId: customerId, tenantId: tenantId);
    return _wishlists.putIfAbsent(
      key,
      () => _buildDefaultWishlist(customerId: customerId, tenantId: tenantId),
    );
  }

  @override
  Future<Wishlist> addToWishlist({
    required String customerId,
    required String tenantId,
    required String productId,
    String? variantId,
  }) async {
    await _simulateDelay();

    final currentWishlist = await getWishlist(
      customerId: customerId,
      tenantId: tenantId,
    );

    final exists = currentWishlist.items.any(
      (item) => item.productId == productId && item.variantId == variantId,
    );
    if (exists) {
      return currentWishlist;
    }

    final now = DateTime.now();

    final newItem = WishlistItem(
      id: 'wish_${now.microsecondsSinceEpoch}',
      wishlistId: currentWishlist.id,
      productId: productId,
      variantId: variantId,
      addedAt: now,
      productName: productId == 'd1a6e0d7-6e7a-4c41-93a2-2c8f9b101111'
          ? 'Sneaker Cart Test - 42 / White'
          : 'Áo thun Oversize Cart Test - M / Black',
      sku: productId == 'd1a6e0d7-6e7a-4c41-93a2-2c8f9b101111'
          ? 'CART-SNEAKER-42'
          : 'CART-TSHIRT-M-BLACK',
      productType: variantId != null ? 'variant' : 'standalone',
      productStatus: 'selling',
      sellingPrice: productId == 'd1a6e0d7-6e7a-4c41-93a2-2c8f9b101111'
          ? '1590000'
          : '249000',
      originalPrice: productId == 'd1a6e0d7-6e7a-4c41-93a2-2c8f9b101111'
          ? '1890000'
          : '299000',
      thumbnailUrl: productId == 'd1a6e0d7-6e7a-4c41-93a2-2c8f9b101111'
          ? 'https://cdn.example.com/products/sneaker-42-white-main.jpg'
          : 'https://cdn.example.com/products/tshirt-m-black-main.jpg',
      variantSummary: variantId != null
          ? (productId == 'd1a6e0d7-6e7a-4c41-93a2-2c8f9b101111'
                ? '42, White'
                : 'M, Black')
          : null,
      attributes: variantId != null
          ? _wishlistAttrs(
              productId == 'd1a6e0d7-6e7a-4c41-93a2-2c8f9b101111'
                  ? [
                      {'label': 'Size', 'value': '42'},
                      {'label': 'Color', 'value': 'White'},
                    ]
                  : [
                      {'label': 'Size', 'value': 'M'},
                      {'label': 'Color', 'value': 'Black'},
                    ],
            )
          : const [],
      isAvailable: true,
    );

    final updatedItems = [...currentWishlist.items, newItem];
    final updatedWishlist = currentWishlist.copyWith(
      items: updatedItems,
      totalItems: updatedItems.length,
      updatedAt: now,
    );

    final key = _key(customerId: customerId, tenantId: tenantId);
    _wishlists[key] = updatedWishlist;
    return updatedWishlist;
  }

  @override
  Future<Wishlist> removeFromWishlist({
    required String customerId,
    required String tenantId,
    required String itemId,
  }) async {
    await _simulateDelay();

    final currentWishlist = await getWishlist(
      customerId: customerId,
      tenantId: tenantId,
    );

    final updatedItems = currentWishlist.items
        .where((item) => item.id != itemId)
        .toList();

    final updatedWishlist = currentWishlist.copyWith(
      items: updatedItems,
      totalItems: updatedItems.length,
      updatedAt: DateTime.now(),
    );

    final key = _key(customerId: customerId, tenantId: tenantId);
    _wishlists[key] = updatedWishlist;
    return updatedWishlist;
  }

  @override
  Future<Cart> moveWishlistItemToCart({
    required String customerId,
    required String tenantId,
    required String wishlistItemId,
    int quantity = 1,
  }) async {
    await _simulateDelay();

    final wishlist = await getWishlist(
      customerId: customerId,
      tenantId: tenantId,
    );
    final wishItem = wishlist.items.firstWhere(
      (item) => item.id == wishlistItemId,
    );

    final cart = await addCartItem(
      customerId: customerId,
      tenantId: tenantId,
      productId: wishItem.productId,
      variantId: wishItem.variantId,
      quantity: quantity,
    );

    await removeFromWishlist(
      customerId: customerId,
      tenantId: tenantId,
      itemId: wishlistItemId,
    );

    return cart;
  }
}
