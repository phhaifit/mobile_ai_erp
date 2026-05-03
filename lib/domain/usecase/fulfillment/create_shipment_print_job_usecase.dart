import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class CreateShipmentPrintJobParams {
  final String orderId;
  final String shipmentId;
  final String? artifactId;
  final String artifactType;
  final String format;
  final String? printerName;
  final String? printerCode;
  final int copies;
  final Map<String, dynamic>? payload;
  final Map<String, dynamic>? metadata;

  CreateShipmentPrintJobParams({
    required this.orderId,
    required this.shipmentId,
    this.artifactId,
    this.artifactType = 'shipping_label',
    this.format = 'pdf',
    this.printerName,
    this.printerCode,
    this.copies = 1,
    this.payload,
    this.metadata,
  });
}

class CreateShipmentPrintJobUseCase
    extends UseCase<ShipmentPrintJob, CreateShipmentPrintJobParams> {
  final FulfillmentRepository _repository;

  CreateShipmentPrintJobUseCase(this._repository);

  @override
  Future<ShipmentPrintJob> call({
    required CreateShipmentPrintJobParams params,
  }) {
    return _repository.createShipmentPrintJob(
      params.orderId,
      params.shipmentId,
      artifactId: params.artifactId,
      artifactType: params.artifactType,
      format: params.format,
      printerName: params.printerName,
      printerCode: params.printerCode,
      copies: params.copies,
      payload: params.payload,
      metadata: params.metadata,
    );
  }
}
