import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import '../../constants/endpoints.dart';

class CartApi {
  final DioClient _dioClient;

  CartApi(this._dioClient);

  Future<Map<String, dynamic>> getCart() async {
    final res = await _dioClient.dio.get(Endpoints.storefrontCart);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getCartSummary() async {
    final res = await _dioClient.dio.get(Endpoints.storefrontCartSummary);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> addCartItem({
    required String productId,
    required int quantity,
  }) async {
    final res = await _dioClient.dio.post(
      Endpoints.storefrontCartItems,
      data: {'product_id': productId, 'quantity': quantity},
    );

    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    final res = await _dioClient.dio.patch(
      Endpoints.storefrontCartItemById(itemId),
      data: {'quantity': quantity},
    );

    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> removeCartItem({required String itemId}) async {
    await _dioClient.dio.delete(Endpoints.storefrontCartItemById(itemId));
  }

  Future<Map<String, dynamic>> calculateCart({
    required List<String> itemIds,
    String? couponCode,
  }) async {
    final body = <String, dynamic>{
      'itemIds': itemIds,
      if (couponCode != null && couponCode.trim().isNotEmpty)
        'couponCode': couponCode.trim(),
    };

    final res = await _dioClient.dio.post(
      Endpoints.storefrontCartCalculate,
      data: body,
    );

    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> mergeCart({
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await _dioClient.dio.post(
      Endpoints.storefrontCartMerge,
      data: {'items': items},
    );

    return Map<String, dynamic>.from(res.data as Map);
  }
}
