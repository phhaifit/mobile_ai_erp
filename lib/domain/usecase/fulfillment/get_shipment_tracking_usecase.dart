import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class GetShipmentTrackingParams {
  final String orderId;
  final bool refresh;

  GetShipmentTrackingParams({required this.orderId, this.refresh = false});
}

class GetShipmentTrackingUseCase
    extends UseCase<ShipmentTrackingInfo?, GetShipmentTrackingParams> {
  final FulfillmentRepository _repository;

  GetShipmentTrackingUseCase(this._repository);

  @override
  Future<ShipmentTrackingInfo?> call({
    required GetShipmentTrackingParams params,
  }) {
    return _repository.getShipmentTracking(
      params.orderId,
      refresh: params.refresh,
    );
  }
}
