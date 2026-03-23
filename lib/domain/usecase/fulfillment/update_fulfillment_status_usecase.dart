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
  Future<void> call({required UpdateFulfillmentStatusParams params}) async {
    final order = await _repository.getOrderById(params.orderId);
    if (order == null) {
      throw Exception('Order not found: ${params.orderId}');
    }

    switch (params.status) {
      case FulfillmentStatus.packing:
        if (!order.isFullyPicked) {
          throw Exception('All items must be picked before packing');
        }
        break;
      case FulfillmentStatus.packed:
        if (!order.isFullyPacked) {
          throw Exception(
              'All items must be packed into packages before marking as packed');
        }
        break;
      case FulfillmentStatus.shipped:
        if (!order.isFullyPacked) {
          throw Exception('All items must be packed before shipping');
        }
        break;
      default:
        break;
    }

    return _repository.updateOrderStatus(params.orderId, params.status);
  }
}
