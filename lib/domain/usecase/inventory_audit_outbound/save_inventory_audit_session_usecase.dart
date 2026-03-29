import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_line.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_record.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';

class SaveInventoryAuditSessionParams {
  const SaveInventoryAuditSessionParams({
    required this.warehouseId,
    required this.lines,
  });

  final String warehouseId;
  final List<AuditLine> lines;
}

class SaveInventoryAuditSessionUseCase
    extends UseCase<AuditRecord, SaveInventoryAuditSessionParams> {
  SaveInventoryAuditSessionUseCase(this._repository);

  final InventoryAuditOutboundRepository _repository;

  @override
  Future<AuditRecord> call({required SaveInventoryAuditSessionParams params}) {
    return _repository.saveAuditSession(
      warehouseId: params.warehouseId,
      lines: params.lines,
    );
  }
}
