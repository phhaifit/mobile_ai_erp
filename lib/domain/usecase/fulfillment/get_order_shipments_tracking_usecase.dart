import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class GetOrderShipmentsTrackingParams {
  final String orderId;
  final bool refresh;

  GetOrderShipmentsTrackingParams({
    required this.orderId,
    this.refresh = false,
  });
}

class GetOrderShipmentsTrackingUseCase
    extends UseCase<OrderShipmentsTrackingInfo?, GetOrderShipmentsTrackingParams> {
  final FulfillmentRepository _repository;

  GetOrderShipmentsTrackingUseCase(this._repository);

  @override
  Future<OrderShipmentsTrackingInfo?> call({
    required GetOrderShipmentsTrackingParams params,
  }) {
    return _repository.getOrderShipmentsTracking(
      params.orderId,
      refresh: params.refresh,
    );
  }
}
