import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class CreateOrLinkShipmentParams {
  final String orderId;
  final String? trackingCode;
  final String? note;

  CreateOrLinkShipmentParams({
    required this.orderId,
    this.trackingCode,
    this.note,
  });
}

class CreateOrLinkShipmentUseCase
    extends UseCase<ShipmentTrackingInfo, CreateOrLinkShipmentParams> {
  final FulfillmentRepository _repository;

  CreateOrLinkShipmentUseCase(this._repository);

  @override
  Future<ShipmentTrackingInfo> call({
    required CreateOrLinkShipmentParams params,
  }) {
    return _repository.createOrLinkShipment(
      params.orderId,
      trackingCode: params.trackingCode,
      note: params.note,
    );
  }
}
