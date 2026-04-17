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
    bool? includeInactive,
    bool? hasProducts,
    String? sortBy,
    String? sortOrder,
  });

  Future<Supplier?> getById(String id);

  Future<Supplier> add(SupplierUpsertPayload payload);

  Future<Supplier> update(String id, SupplierUpsertPayload payload);

  Future<void> delete(String id);

  Future<List<SupplierProductLink>> getSupplierProducts(
    String supplierId, {
    int page = 1,
    int pageSize = 50,
  });

  Future<void> addProductToSupplier(
    String productId,
    String supplierId, {
    String? supplierSku,
    double? costPrice,
    bool isPrimary = false,
  });

  Future<void> updateProductSupplierLink(
    String productId,
    String supplierId, {
    String? supplierSku,
    double? costPrice,
    bool? isPrimary,
  });

  Future<void> removeProductFromSupplier(String productId, String supplierId);

  Future<PaginatedResult<ProductSummary>> searchProducts({
    String search = '',
    int page = 1,
    int pageSize = 20,
  });
}
