import '../../entity/shared/paginated_result.dart';
import '../../entity/supplier/product_summary.dart';
import '../../entity/supplier/supplier.dart';
import '../../entity/supplier/supplier_product_link.dart';
import '../../entity/supplier/supplier_upsert_payload.dart';

abstract class SupplierRepository {
  Future<PaginatedResult<Supplier>> getSuppliers({
    String search = '',
    int page = 1,
    int pageSize = 10,
  });

  Future<Supplier?> getById(String id);
  Future<Supplier> add(SupplierUpsertPayload payload);
  Future<Supplier> update(String id, SupplierUpsertPayload payload);
  Future<void> delete(String id);
  Future<List<SupplierProductLink>> getSupplierProducts(String supplierId);
  Future<void> saveSupplierProducts(
    String supplierId,
    List<SupplierProductLink> items,
  );
  Future<PaginatedResult<ProductSummary>> searchProducts({
    String search = '',
    int page = 1,
    int pageSize = 10,
  });
}
