import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

class WishlistApi {
  final DioClient _dioClient;

  WishlistApi(this._dioClient);

  Future<Map<String, dynamic>> getWishlist() async {
    final res = await _dioClient.dio.get(Endpoints.storefrontWishlist);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getWishlistSummary() async {
    final res = await _dioClient.dio.get(Endpoints.storefrontWishlistSummary);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> addToWishlist({
    required String productId,
  }) async {
    final res = await _dioClient.dio.post(
      Endpoints.storefrontWishlistItems,
      data: {'product_id': productId},
    );

    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> removeFromWishlist({required String itemId}) async {
    await _dioClient.dio.delete(Endpoints.storefrontWishlistItemById(itemId));
  }

  Future<Map<String, dynamic>> mergeWishlist({
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await _dioClient.dio.post(
      Endpoints.storefrontWishlistMerge,
      data: {'items': items},
    );

    return Map<String, dynamic>.from(res.data as Map);
  }
}
