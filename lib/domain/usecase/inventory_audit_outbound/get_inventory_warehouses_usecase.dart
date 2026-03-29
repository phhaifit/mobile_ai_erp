import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_warehouse.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';

class GetInventoryWarehousesUseCase
    extends UseCase<List<InventoryWarehouse>, void> {
  GetInventoryWarehousesUseCase(this._repository);

  final InventoryAuditOutboundRepository _repository;

  @override
  Future<List<InventoryWarehouse>> call({required void params}) {
    return _repository.getWarehouses();
  }
}
