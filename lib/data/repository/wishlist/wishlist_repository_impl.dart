import 'package:mobile_ai_erp/data/network/apis/wishlist/wishlist_api.dart';
import 'package:mobile_ai_erp/data/repository/wishlist/wishlist_repository.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistApi _wishlistApi;

  WishlistRepositoryImpl({required WishlistApi wishlistApi})
    : _wishlistApi = wishlistApi;

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
