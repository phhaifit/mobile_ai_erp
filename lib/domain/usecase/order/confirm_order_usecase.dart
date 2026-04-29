import '../../../core/domain/usecase/use_case.dart';
import '../../repository/account/order_repository.dart';

class ConfirmOrderUsecase extends UseCase<void, String> {
  final OrderRepository _repository;

  ConfirmOrderUsecase(this._repository);

  @override
  Future<void> call({required String params}) {
    return _repository.confirmOrder(params); // params is the orderId
  }
}