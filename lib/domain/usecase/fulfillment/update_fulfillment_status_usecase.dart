import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class UpdateFulfillmentStatusParams {
  final String orderId;
  final FulfillmentStatus status;

  UpdateFulfillmentStatusParams({
    required this.orderId,
    required this.status,
  });
}

class UpdateFulfillmentStatusUseCase
    extends UseCase<void, UpdateFulfillmentStatusParams> {
  final FulfillmentRepository _repository;

  UpdateFulfillmentStatusUseCase(this._repository);

  @override
  Future<void> call({required UpdateFulfillmentStatusParams params}) {
    // Validation is now handled by the BE API.
    // The API will return appropriate error responses for invalid transitions.
    return _repository.updateOrderStatus(params.orderId, params.status);
  }
}
