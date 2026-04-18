import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

class CartApi {
  final DioClient _dioClient;

  CartApi(this._dioClient);

  Future<Map<String, dynamic>> getCart({required String tenantId}) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.storefrontCart,
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCartSummary({
    required String tenantId,
  }) async {
    try {
      final res = await _dioClient.dio.get(
        Endpoints.storefrontCartSummary,
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addCartItem({
    required String tenantId,
    required String productId,
    String? variantId,
    required int quantity,
  }) async {
    try {
      final body = <String, dynamic>{
        'product_id': productId,
        'quantity': quantity,
      };

      if (variantId != null) {
        body['variant_id'] = variantId;
      }

      final res = await _dioClient.dio.post(
        Endpoints.storefrontCartItems,
        data: body,
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCartItemQuantity({
    required String tenantId,
    required String itemId,
    required int quantity,
  }) async {
    try {
      final res = await _dioClient.dio.patch(
        '${Endpoints.storefrontCartItems}/$itemId',
        data: {'quantity': quantity},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> removeCartItem({
    required String tenantId,
    required String itemId,
  }) async {
    try {
      final res = await _dioClient.dio.delete(
        '${Endpoints.storefrontCartItems}/$itemId',
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> calculateCart({
    required String tenantId,
    required List<String> selectedItemIds,
    String? couponCode,
  }) async {
    try {
      final body = <String, dynamic>{'selected_item_ids': selectedItemIds};

      if (couponCode != null && couponCode.trim().isNotEmpty) {
        body['coupon_code'] = couponCode;
      }

      final res = await _dioClient.dio.post(
        Endpoints.storefrontCartCalculate,
        data: body,
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> mergeCart({
    required String tenantId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final res = await _dioClient.dio.post(
        Endpoints.storefrontCartMerge,
        data: {'items': items},
        options: Options(headers: {'x-tenant-id': tenantId}),
      );

      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      rethrow;
    }
  }
}
