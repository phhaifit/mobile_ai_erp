import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/entity/payment/payment.dart';

class StorefrontPaymentsApi {
  final Dio _dio;

  StorefrontPaymentsApi(this._dio);

  /// GET /storefront/payments?page=1&pageSize=10
  Future<StorefrontPaymentsResult> getPayments({
    int page = 1,
    int pageSize = 10,
  }) async {
    final res = await _dio.get(
      Endpoints.storefrontPayments,
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final data = res.data as Map<String, dynamic>;
    final paymentsList = (data['data'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(Payment.fromJson)
            .toList() ??
        [];
    // Backend returns total/page/pageSize at top level (no meta wrapper)
    return StorefrontPaymentsResult(
      payments: paymentsList,
      total: data['total'] as int? ?? paymentsList.length,
      page: data['page'] as int? ?? page,
      pageSize: data['pageSize'] as int? ?? pageSize,
    );
  }

  /// GET /storefront/payments/:id
  Future<Payment> getPaymentById(String id) async {
    final res =
        await _dio.get(Endpoints.storefrontPaymentById(id));
    return Payment.fromJson(res.data as Map<String, dynamic>);
  }
}

class StorefrontPaymentsResult {
  final List<Payment> payments;
  final int total;
  final int page;
  final int pageSize;

  StorefrontPaymentsResult({
    required this.payments,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}
