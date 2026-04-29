import 'package:mobile_ai_erp/data/network/apis/cart/cart_api.dart';
import 'package:mobile_ai_erp/data/network/apis/wishlist/wishlist_api.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_calculation.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';

class CartRepositoryImpl implements CartRepository {
  final CartApi _cartApi;
  final WishlistApi _wishlistApi;

  CartRepositoryImpl({
    required CartApi cartApi,
    required WishlistApi wishlistApi,
  }) : _cartApi = cartApi,
       _wishlistApi = wishlistApi;

  @override
  Future<Cart> getCart() async {
    final res = await _cartApi.getCart();
    return _mapCart(_unwrapData(res));
  }

  @override
  Future<Map<String, dynamic>> getCartSummary() async {
    final res = await _cartApi.getCartSummary();
    return _unwrapData(res);
  }

  @override
  Future<Cart> addCartItem({
    required String productId,
    required int quantity,
  }) async {
    final res = await _cartApi.addCartItem(
      productId: productId,
      quantity: quantity,
    );
    return _mapCart(_unwrapData(res));
  }

  @override
  Future<Cart> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    final res = await _cartApi.updateCartItemQuantity(
      itemId: itemId,
      quantity: quantity,
    );
    return _mapCart(_unwrapData(res));
  }

  @override
  Future<void> removeCartItem({required String itemId}) async {
    await _cartApi.removeCartItem(itemId: itemId);
  }

  @override
  Future<CartCalculation> calculateCart({
    required List<String> selectedItemIds,
    String? couponCode,
  }) async {
    final res = await _cartApi.calculateCart(
      itemIds: selectedItemIds,
      couponCode: couponCode,
    );
    return _mapCartCalculation(_unwrapData(res));
  }

  @override
  Future<Cart> mergeCart({required List<Map<String, dynamic>> items}) async {
    final res = await _cartApi.mergeCart(items: items);
    return _mapCart(_unwrapData(res));
  }

  @override
  Future<Wishlist> getWishlist() async {
    final res = await _wishlistApi.getWishlist();
    return _mapWishlist(_unwrapData(res));
  }

  @override
  Future<Map<String, dynamic>> getWishlistSummary() async {
    final res = await _wishlistApi.getWishlistSummary();
    return _unwrapData(res);
  }

  @override
  Future<Wishlist> addToWishlist({required String productId}) async {
    final res = await _wishlistApi.addToWishlist(productId: productId);
    return _mapWishlist(_unwrapData(res));
  }

  @override
  Future<void> removeFromWishlist({required String itemId}) async {
    await _wishlistApi.removeFromWishlist(itemId: itemId);
  }

  @override
  Future<Wishlist> mergeWishlist({
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await _wishlistApi.mergeWishlist(items: items);
    return _mapWishlist(_unwrapData(res));
  }

  Map<String, dynamic> _unwrapData(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return json;
  }

  List<Map<String, dynamic>> _asListOfMap(dynamic value) {
    if (value == null) return [];
    return (value as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Cart _mapCart(Map<String, dynamic> json) {
    final itemsJson = _asListOfMap(json['items']);
    final cartId = (json['id'] ?? '').toString();

    return Cart(
      id: cartId,
      tenantId: (json['tenantId'] ?? json['tenant_id'] ?? '').toString(),
      customerId: (json['customerId'] ?? json['customer_id'] ?? '').toString(),
      subtotal: (json['subtotal'] ?? '0').toString(),
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      items: itemsJson.map((e) => _mapCartItem(e, cartId)).toList(),
      createdAt: DateTime.parse(
        (json['createdAt'] ?? json['created_at']).toString(),
      ),
      updatedAt: DateTime.parse(
        (json['updatedAt'] ?? json['updated_at']).toString(),
      ),
    );
  }

  CartItem _mapCartItem(Map<String, dynamic> json, String cartId) {
    final attributesJson = _asListOfMap(json['attributes']);

    return CartItem(
      id: (json['id'] ?? '').toString(),
      cartId: cartId,
      productId: (json['productId'] ?? json['product_id'] ?? '').toString(),
      variantId: json['variantId']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] ?? '0').toString(),
      originalPrice: json['originalPrice']?.toString(),
      lineTotal: (json['lineTotal'] ?? '0').toString(),
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'].toString())
          : DateTime.now(),
      productName: (json['productName'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      productType: (json['productType'] ?? '').toString(),
      productStatus: (json['productStatus'] ?? '').toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      variantSummary: json['variantSummary']?.toString(),
      attributes: attributesJson
          .map(
            (attr) => CartItemAttribute(
              label: (attr['label'] ?? '').toString(),
              value: (attr['value'] ?? '').toString(),
            ),
          )
          .toList(),
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      isPriceChanged: json['isPriceChanged'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      stockWarning: json['stockWarning'] as bool? ?? false,
    );
  }

  CartCalculation _mapCartCalculation(Map<String, dynamic> json) {
    final itemsJson = _asListOfMap(json['items']);
    final summaryJson = Map<String, dynamic>.from(
      (json['summary'] ?? {}) as Map,
    );
    final couponJson = json['coupon'] is Map
        ? Map<String, dynamic>.from(json['coupon'] as Map)
        : null;

    return CartCalculation(
      items: itemsJson.map((e) => _mapCartCalculationItem(e)).toList(),
      summary: CartCalculationSummary(
        subtotal: (summaryJson['subtotal'] ?? '0').toString(),
        discount: (summaryJson['discount'] ?? '0').toString(),
        total: (summaryJson['total'] ?? '0').toString(),
        selectedItemsCount:
            (summaryJson['selectedItemsCount'] as num?)?.toInt() ?? 0,
        selectedQuantity:
            (summaryJson['selectedQuantity'] as num?)?.toInt() ?? 0,
      ),
      coupon: couponJson == null
          ? null
          : AppliedCoupon(
              code: (couponJson['code'] ?? '').toString(),
              name: couponJson['name']?.toString(),
              isApplied: couponJson['isApplied'] as bool? ?? false,
              isValid: couponJson['isValid'] as bool? ?? false,
              discountAmount: couponJson['discountAmount']?.toString(),
              reason: couponJson['reason']?.toString(),
            ),
    );
  }

  CartItem _mapCartCalculationItem(Map<String, dynamic> json) {
    final attributesJson = _asListOfMap(json['attributes']);

    return CartItem(
      id: (json['id'] ?? '').toString(),
      cartId: '',
      productId: (json['productId'] ?? json['product_id'] ?? '').toString(),
      variantId: json['variantId']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] ?? '0').toString(),
      originalPrice: json['originalPrice']?.toString(),
      lineTotal: (json['lineTotal'] ?? '0').toString(),
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'].toString())
          : DateTime.now(),
      productName: (json['productName'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      productType: (json['productType'] ?? '').toString(),
      productStatus: (json['productStatus'] ?? '').toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      variantSummary: json['variantSummary']?.toString(),
      attributes: attributesJson
          .map(
            (attr) => CartItemAttribute(
              label: (attr['label'] ?? '').toString(),
              value: (attr['value'] ?? '').toString(),
            ),
          )
          .toList(),
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      isPriceChanged: json['isPriceChanged'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? false,
      stockWarning: json['stockWarning'] as bool? ?? false,
    );
  }

  Wishlist _mapWishlist(Map<String, dynamic> json) {
    final itemsJson = _asListOfMap(json['items']);
    final wishlistId = (json['id'] ?? '').toString();

    return Wishlist(
      id: wishlistId,
      tenantId: (json['tenantId'] ?? json['tenant_id'] ?? '').toString(),
      customerId: (json['customerId'] ?? json['customer_id'] ?? '').toString(),
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      items: itemsJson.map((e) => _mapWishlistItem(e, wishlistId)).toList(),
      createdAt: DateTime.parse(
        (json['createdAt'] ?? json['created_at']).toString(),
      ),
      updatedAt: DateTime.parse(
        (json['updatedAt'] ?? json['updated_at']).toString(),
      ),
    );
  }

  WishlistItem _mapWishlistItem(Map<String, dynamic> json, String wishlistId) {
    final attributesJson = _asListOfMap(json['attributes']);

    return WishlistItem(
      id: (json['id'] ?? '').toString(),
      wishlistId: wishlistId,
      productId: (json['productId'] ?? json['product_id'] ?? '').toString(),
      variantId: json['variantId']?.toString(),
      addedAt: DateTime.parse(json['addedAt'].toString()),
      productName: (json['productName'] ?? '').toString(),
      sku: (json['sku'] ?? '').toString(),
      productType: (json['productType'] ?? '').toString(),
      productStatus: (json['productStatus'] ?? '').toString(),
      sellingPrice: (json['sellingPrice'] ?? '0').toString(),
      originalPrice: json['originalPrice']?.toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      variantSummary: json['variantSummary']?.toString(),
      attributes: attributesJson
          .map(
            (attr) => WishlistItemAttribute(
              label: (attr['label'] ?? '').toString(),
              value: (attr['value'] ?? '').toString(),
            ),
          )
          .toList(),
      isAvailable: json['isAvailable'] as bool? ?? false,
    );
  }
}
