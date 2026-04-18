import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

class WishlistApi {
  final DioClient _dioClient;

  WishlistApi(this._dioClient);

  Future<Map<String, dynamic>> getWishlist({required String tenantId}) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.storefrontWishlist,
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWishlistSummary({
    required String tenantId,
  }) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.storefrontWishlistSummary,
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addToWishlist({
    required String tenantId,
    required String productId,
    String? variantId,
  }) async {
    try {
      final body = <String, dynamic>{'product_id': productId};

      if (variantId != null) {
        body['variant_id'] = variantId;
      }

      final res = await _dioClient.dio.post(
        Endpoints.storefrontWishlistItems,
        data: body,
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> removeFromWishlist({
    required String tenantId,
    required String itemId,
  }) async {
    try {
      final res = await _dioClient.dio.delete(
        '${Endpoints.storefrontWishlistItems}/$itemId',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> mergeWishlist({
    required String tenantId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.storefrontWishlistMerge,
        data: {'items': items},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }
}
