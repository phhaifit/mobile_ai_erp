import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class CouponApi {
  final DioClient _dioClient;

  CouponApi(this._dioClient);

  Future<List<Map<String, dynamic>>> getCoupons() async {
    final res = await _dioClient.dio.get(Endpoints.storefrontCoupons);

    final data = res.data;

    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> validateCoupon({
    required String couponCode,
    required num subtotal,
  }) async {
    final res = await _dioClient.dio.post(
      Endpoints.storefrontCouponsValidate,
      data: {'code': couponCode, 'subtotal': subtotal},
    );

    return Map<String, dynamic>.from(res.data as Map);
  }
}
