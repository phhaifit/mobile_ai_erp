import '../../../core/domain/usecase/use_case.dart';
import '../../entity/storefront_order/order.dart';
import '../../repository/account/order_repository.dart';

class GetOrderHistoryParams {
  final String? status;
  final int? page;
  final int? pageSize;

  GetOrderHistoryParams({this.status, this.page, this.pageSize});
}

class GetOrderHistoryUseCase extends UseCase<List<StorefrontOrder>, GetOrderHistoryParams> {
  final StorefrontOrderRepository _repository;

  GetOrderHistoryUseCase(this._repository);

  @override
  Future<List<StorefrontOrder>> call({required GetOrderHistoryParams params}) {
    return _repository.getOrderHistory(
      status: params.status,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}