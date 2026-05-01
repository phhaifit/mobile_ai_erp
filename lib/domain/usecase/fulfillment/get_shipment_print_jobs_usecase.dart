import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class GetShipmentPrintJobsParams {
  final String orderId;
  final String shipmentId;

  GetShipmentPrintJobsParams({
    required this.orderId,
    required this.shipmentId,
  });
}

class GetShipmentPrintJobsUseCase
    extends UseCase<List<ShipmentPrintJob>, GetShipmentPrintJobsParams> {
  final FulfillmentRepository _repository;

  GetShipmentPrintJobsUseCase(this._repository);

  @override
  Future<List<ShipmentPrintJob>> call({
    required GetShipmentPrintJobsParams params,
  }) {
    return _repository.getShipmentPrintJobs(params.orderId, params.shipmentId);
  }
}
