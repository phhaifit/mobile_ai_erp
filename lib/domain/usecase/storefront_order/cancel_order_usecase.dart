import '../../../core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/storefront_account/order_repository.dart';

class CancelOrderUseCase extends UseCase<void, String> {
  final StorefrontOrderRepository _repository;

  CancelOrderUseCase(this._repository);

  @override
  Future<void> call({required String params}) {
    return _repository.cancelOrder(params); // params is the orderId
  }
}