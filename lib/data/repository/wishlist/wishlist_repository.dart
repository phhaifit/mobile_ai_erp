import 'package:mobile_ai_erp/domain/entity/cart/wishlist.dart';

abstract class WishlistRepository {
  Future<Wishlist> getWishlist();

  Future<Map<String, dynamic>> getWishlistSummary();

  Future<Wishlist> addToWishlist({required String productId});

  Future<void> removeFromWishlist({required String itemId});

  Future<Wishlist> mergeWishlist({required List<Map<String, dynamic>> items});
}
