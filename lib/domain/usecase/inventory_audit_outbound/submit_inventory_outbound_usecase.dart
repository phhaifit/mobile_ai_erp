import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/outbound_record.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';

class SubmitInventoryOutboundParams {
  const SubmitInventoryOutboundParams({
    required this.warehouseId,
    required this.productId,
    required this.quantity,
    this.note,
  });

  final String warehouseId;
  final String productId;
  final int quantity;
  final String? note;
}

class SubmitInventoryOutboundUseCase
    extends UseCase<OutboundRecord, SubmitInventoryOutboundParams> {
  SubmitInventoryOutboundUseCase(this._repository);

  final InventoryAuditOutboundRepository _repository;

  @override
  Future<OutboundRecord> call({required SubmitInventoryOutboundParams params}) {
    return _repository.submitOutbound(
      warehouseId: params.warehouseId,
      productId: params.productId,
      quantity: params.quantity,
      note: params.note,
    );
  }
}
