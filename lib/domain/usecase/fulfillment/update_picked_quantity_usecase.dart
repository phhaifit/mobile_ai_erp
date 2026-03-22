import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class UpdatePickedQuantityParams {
  final String orderId;
  final String itemId;
  final int quantity;

  UpdatePickedQuantityParams({
    required this.orderId,
    required this.itemId,
    required this.quantity,
  });
}

class UpdatePickedQuantityUseCase
    extends UseCase<void, UpdatePickedQuantityParams> {
  final FulfillmentRepository _repository;

  UpdatePickedQuantityUseCase(this._repository);

  @override
  Future<void> call({required UpdatePickedQuantityParams params}) {
    return _repository.updateItemPickedQty(
        params.orderId, params.itemId, params.quantity);
  }
}
