import 'package:mobile_ai_erp/data/local/datasources/cart/cart_datasource.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_calculation.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist.dart';

class CartRepositoryImpl implements CartRepository {
  final CartDataSource _dataSource;

  CartRepositoryImpl({required CartDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Cart> getCart({
    required String customerId,
    required String tenantId,
  }) async {
    return _dataSource.getCart(customerId: customerId, tenantId: tenantId);
  }

  @override
  Future<Cart> addCartItem({
    required String customerId,
    required String tenantId,
    required String productId,
    String? variantId,
    required int quantity,
  }) async {
    return _dataSource.addCartItem(
      customerId: customerId,
      tenantId: tenantId,
      productId: productId,
      variantId: variantId,
      quantity: quantity,
    );
  }

  @override
  Future<Cart> updateCartItemQuantity({
    required String customerId,
    required String tenantId,
    required String itemId,
    required int quantity,
  }) async {
    return _dataSource.updateCartItemQuantity(
      customerId: customerId,
      tenantId: tenantId,
      itemId: itemId,
      quantity: quantity,
    );
  }

  @override
  Future<Cart> removeCartItem({
    required String customerId,
    required String tenantId,
    required String itemId,
  }) async {
    return _dataSource.removeCartItem(
      customerId: customerId,
      tenantId: tenantId,
      itemId: itemId,
    );
  }

  @override
  Future<CartCalculation> calculateCart({
    required String customerId,
    required String tenantId,
    required List<String> selectedItemIds,
    String? couponCode,
  }) async {
    return _dataSource.calculateCart(
      customerId: customerId,
      tenantId: tenantId,
      selectedItemIds: selectedItemIds,
      couponCode: couponCode,
    );
  }

  @override
  Future<Wishlist> getWishlist({
    required String customerId,
    required String tenantId,
  }) async {
    return _dataSource.getWishlist(customerId: customerId, tenantId: tenantId);
  }

  @override
  Future<Wishlist> addToWishlist({
    required String customerId,
    required String tenantId,
    required String productId,
    String? variantId,
  }) async {
    return _dataSource.addToWishlist(
      customerId: customerId,
      tenantId: tenantId,
      productId: productId,
      variantId: variantId,
    );
  }

  @override
  Future<Wishlist> removeFromWishlist({
    required String customerId,
    required String tenantId,
    required String itemId,
  }) async {
    return _dataSource.removeFromWishlist(
      customerId: customerId,
      tenantId: tenantId,
      itemId: itemId,
    );
  }

  @override
  Future<Cart> moveWishlistItemToCart({
    required String customerId,
    required String tenantId,
    required String wishlistItemId,
    int quantity = 1,
  }) async {
    return _dataSource.moveWishlistItemToCart(
      customerId: customerId,
      tenantId: tenantId,
      wishlistItemId: wishlistItemId,
      quantity: quantity,
    );
  }
}
