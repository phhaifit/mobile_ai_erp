import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_item.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';

class GetInventoryByWarehouseUseCase extends UseCase<List<InventoryItem>, String> {
  GetInventoryByWarehouseUseCase(this._repository);

  final InventoryAuditOutboundRepository _repository;

  @override
  Future<List<InventoryItem>> call({required String params}) {
    return _repository.getInventoryByWarehouse(params);
  }
}
