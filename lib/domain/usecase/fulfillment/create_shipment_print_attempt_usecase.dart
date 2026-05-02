import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';

class CreateShipmentPrintAttemptParams {
  final String orderId;
  final String shipmentId;
  final String printJobId;
  final String status;
  final String? spoolJobId;
  final String? errorCode;
  final String? errorMessage;
  final int? durationMs;
  final Map<String, dynamic>? printerResponse;

  CreateShipmentPrintAttemptParams({
    required this.orderId,
    required this.shipmentId,
    required this.printJobId,
    required this.status,
    this.spoolJobId,
    this.errorCode,
    this.errorMessage,
    this.durationMs,
    this.printerResponse,
  });
}

class CreateShipmentPrintAttemptUseCase
    extends UseCase<ShipmentPrintJob, CreateShipmentPrintAttemptParams> {
  final FulfillmentRepository _repository;

  CreateShipmentPrintAttemptUseCase(this._repository);

  @override
  Future<ShipmentPrintJob> call({
    required CreateShipmentPrintAttemptParams params,
  }) {
    return _repository.createShipmentPrintAttempt(
      params.orderId,
      params.shipmentId,
      params.printJobId,
      status: params.status,
      spoolJobId: params.spoolJobId,
      errorCode: params.errorCode,
      errorMessage: params.errorMessage,
      durationMs: params.durationMs,
      printerResponse: params.printerResponse,
    );
  }
}
