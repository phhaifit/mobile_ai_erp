import '../../entity/payment/payment.dart';

abstract class PaymentRepository {
  Future<PaymentListResult> getPayments({int page = 1, int pageSize = 10});
  Future<Payment> getPaymentById(String id);
}

class PaymentListResult {
  final List<Payment> payments;
  final int total;
  final int page;
  final int pageSize;

  PaymentListResult({
    required this.payments,
    required this.total,
    required this.page,
    required this.pageSize,
  });
}
