import '../../../core/domain/usecase/use_case.dart';
import '../../entity/storefront_order/order.dart';
import '../../repository/account/order_repository.dart';

class GetOrderDetailsUseCase extends UseCase<StorefrontOrder, String> {
  final StorefrontOrderRepository _repository;

  GetOrderDetailsUseCase(this._repository);

  @override
  Future<StorefrontOrder> call({required String params}) {
    return _repository.getOrderDetails(params); // params is the orderId
  }
}