import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/outbound_record.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';

class GetInventoryOutboundRecordsUseCase
    extends UseCase<List<OutboundRecord>, void> {
  GetInventoryOutboundRecordsUseCase(this._repository);

  final InventoryAuditOutboundRepository _repository;

  @override
  Future<List<OutboundRecord>> call({required void params}) {
    return _repository.getOutboundRecords();
  }
}
