import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class CheckoutApi {
  final DioClient _dioClient;

  CheckoutApi(this._dioClient);

  /// POST /storefront/checkout
  ///
  /// [address] - shipping address string
  /// [paymentMethod] - 'cod' | 'bank_transfer'
  /// [couponCode] - optional coupon code
  /// [shippingFee] - optional shipping fee override
  /// [customerPhone] - optional customer phone
  /// [customerNote] - optional delivery note
  Future<Map<String, dynamic>> checkout({
    required String address,
    required String paymentMethod,
    String? couponCode,
    double? shippingFee,
    String? customerPhone,
    String? customerNote,
  }) async {
    final body = <String, dynamic>{
      'address': address,
      'paymentMethod': paymentMethod,
      if (couponCode != null && couponCode.trim().isNotEmpty)
        'couponCode': couponCode.trim(),
      if (shippingFee != null) 'shippingFee': shippingFee.toStringAsFixed(4),
      if (customerPhone != null) 'customerPhone': customerPhone,
      if (customerNote != null) 'customerNote': customerNote,
    };

    final res = await _dioClient.dio.post(
      Endpoints.storefrontCheckout,
      data: body,
    );

    return Map<String, dynamic>.from(res.data as Map);
  }
}
