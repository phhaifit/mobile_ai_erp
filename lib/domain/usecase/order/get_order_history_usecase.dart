import '../../../core/domain/usecase/use_case.dart';
import '../../entity/order/order.dart';
import '../../repository/account/order_repository.dart';

class GetOrderHistoryParams {
  final String? status;
  final int? page;
  final int? pageSize;

  GetOrderHistoryParams({this.status, this.page, this.pageSize});
}

class GetOrderHistoryUseCase extends UseCase<List<Order>, GetOrderHistoryParams> {
  final OrderRepository _repository;

  GetOrderHistoryUseCase(this._repository);

  @override
  Future<List<Order>> call({required GetOrderHistoryParams params}) {
    return _repository.getOrderHistory(
      status: params.status,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}