import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_record.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';

class GetInventoryAuditRecordsUseCase extends UseCase<List<AuditRecord>, void> {
  GetInventoryAuditRecordsUseCase(this._repository);

  final InventoryAuditOutboundRepository _repository;

  @override
  Future<List<AuditRecord>> call({required void params}) {
    return _repository.getAuditRecords();
  }
}
