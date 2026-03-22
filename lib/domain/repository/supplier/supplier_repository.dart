import '../../entity/supplier/supplier.dart';

abstract class SupplierRepository {
  Future<List<Supplier>> getAll();
  Future<Supplier?> getById(String id);
  Future<void> add(Supplier supplier);
  Future<void> update(Supplier supplier);
  Future<void> delete(String id);

  // Product–Supplier mapping
  Future<List<String>> getSupplierIdsForProduct(String productId);
  Future<void> linkSupplierToProduct(String productId, String supplierId);
  Future<void> unlinkSupplierFromProduct(String productId, String supplierId);
  Future<List<String>> getProductIdsForSupplier(String supplierId);
}
