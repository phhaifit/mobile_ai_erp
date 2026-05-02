import '../../../core/domain/usecase/use_case.dart';
import '../../entity/storefront_order/return_request.dart';
import '../../repository/account/order_repository.dart';

class SubmitReturnParams {
  final String orderId;
  final SubmitReturnPayload payload;

  SubmitReturnParams({required this.orderId, required this.payload});
}

class SubmitReturnRequestUseCase extends UseCase<void, SubmitReturnParams> {
  final StorefrontOrderRepository _repository;

  SubmitReturnRequestUseCase(this._repository);

  @override
  Future<void> call({required SubmitReturnParams params}) {
    return _repository.submitReturnRequest(params.orderId, params.payload.toJson());
  }
}