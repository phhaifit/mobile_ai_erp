import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class GetShipmentLabelArtifactsParams {
  final String orderId;
  final String shipmentId;

  GetShipmentLabelArtifactsParams({
    required this.orderId,
    required this.shipmentId,
  });
}

class GetShipmentLabelArtifactsUseCase
    extends
        UseCase<List<ShipmentLabelArtifact>, GetShipmentLabelArtifactsParams> {
  final FulfillmentRepository _repository;

  GetShipmentLabelArtifactsUseCase(this._repository);

  @override
  Future<List<ShipmentLabelArtifact>> call({
    required GetShipmentLabelArtifactsParams params,
  }) {
    return _repository.getShipmentLabelArtifacts(
      params.orderId,
      params.shipmentId,
    );
  }
}
