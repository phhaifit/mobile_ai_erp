import '../../../core/domain/usecase/use_case.dart';
import '../../entity/order/order.dart';
import '../../repository/account/order_repository.dart';

class GetOrderDetailsUseCase extends UseCase<Order, String> {
  final OrderRepository _repository;

  GetOrderDetailsUseCase(this._repository);

  @override
  Future<Order> call({required String params}) {
    return _repository.getOrderDetails(params); // params is the orderId
  }
}