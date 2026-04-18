import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class CreateOrLinkShipmentParams {
  final String orderId;
  final List<CreateShipmentItemAllocation> items;

  CreateOrLinkShipmentParams({
    required this.orderId,
    this.items = const [],
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
      items: params.items,
    );
  }
}
