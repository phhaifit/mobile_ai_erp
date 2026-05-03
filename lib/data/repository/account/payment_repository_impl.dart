import '../../../domain/entity/payment/payment.dart';
import '../../../domain/repository/account/payment_repository.dart';
import '../../network/apis/storefront/storefront_payments_api.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final StorefrontPaymentsApi _api;

  PaymentRepositoryImpl(this._api);

  @override
  Future<PaymentListResult> getPayments({
    int page = 1,
    int pageSize = 10,
  }) async {
    final result = await _api.getPayments(page: page, pageSize: pageSize);
    return PaymentListResult(
      payments: result.payments,
      total: result.total,
      page: result.page,
      pageSize: result.pageSize,
    );
  }

  @override
  Future<Payment> getPaymentById(String id) => _api.getPaymentById(id);
}
