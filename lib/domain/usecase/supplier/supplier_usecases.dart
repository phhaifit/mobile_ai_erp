// Use cases for supplier management

import '../../entity/shared/paginated_result.dart';
import '../../entity/supplier/product_summary.dart';
import '../../entity/supplier/supplier.dart';
import '../../entity/supplier/supplier_product_link.dart';
import '../../entity/supplier/supplier_upsert_payload.dart';
import '../../repository/supplier/supplier_repository.dart';

class GetSuppliersUseCase {
  final SupplierRepository _repository;

  GetSuppliersUseCase(this._repository);

  Future<PaginatedResult<Supplier>> call({
    String search = '',
    int page = 1,
    int pageSize = 10,
    bool? includeInactive,
    bool? hasProducts,
    String? sortBy,
    String? sortOrder,
  }) {
    return _repository.getSuppliers(
      search: search,
      page: page,
      pageSize: pageSize,
      includeInactive: includeInactive,
      hasProducts: hasProducts,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }
}

class GetSupplierByIdUseCase {
  final SupplierRepository _repository;

  GetSupplierByIdUseCase(this._repository);

  Future<Supplier?> call(String id) => _repository.getById(id);
}

class CreateSupplierUseCase {
  final SupplierRepository _repository;

  CreateSupplierUseCase(this._repository);

  Future<Supplier> call(SupplierUpsertPayload payload) =>
      _repository.add(payload);
}

class UpdateSupplierUseCase {
  final SupplierRepository _repository;

  UpdateSupplierUseCase(this._repository);

  Future<Supplier> call(String id, SupplierUpsertPayload payload) =>
      _repository.update(id, payload);
}

class DeleteSupplierUseCase {
  final SupplierRepository _repository;

  DeleteSupplierUseCase(this._repository);

  Future<void> call(String id) => _repository.delete(id);
}

class GetSupplierProductsUseCase {
  final SupplierRepository _repository;

  GetSupplierProductsUseCase(this._repository);

  Future<List<SupplierProductLink>> call(
    String supplierId, {
    int page = 1,
    int pageSize = 50,
  }) =>
      _repository.getSupplierProducts(supplierId, page: page, pageSize: pageSize);
}

class AddProductToSupplierUseCase {
  final SupplierRepository _repository;

  AddProductToSupplierUseCase(this._repository);

  Future<void> call(
    String productId,
    String supplierId, {
    String? supplierSku,
    double? costPrice,
    bool isPrimary = false,
  }) =>
      _repository.addProductToSupplier(
        productId,
        supplierId,
        supplierSku: supplierSku,
        costPrice: costPrice,
        isPrimary: isPrimary,
      );
}

class UpdateProductSupplierLinkUseCase {
  final SupplierRepository _repository;

  UpdateProductSupplierLinkUseCase(this._repository);

  Future<void> call(
    String productId,
    String supplierId, {
    String? supplierSku,
    double? costPrice,
    bool? isPrimary,
  }) =>
      _repository.updateProductSupplierLink(
        productId,
        supplierId,
        supplierSku: supplierSku,
        costPrice: costPrice,
        isPrimary: isPrimary,
      );
}

class RemoveProductFromSupplierUseCase {
  final SupplierRepository _repository;

  RemoveProductFromSupplierUseCase(this._repository);

  Future<void> call(String productId, String supplierId) =>
      _repository.removeProductFromSupplier(productId, supplierId);
}

class SearchProductsUseCase {
  final SupplierRepository _repository;

  SearchProductsUseCase(this._repository);

  Future<PaginatedResult<ProductSummary>> call({
    String search = '',
    int page = 1,
    int pageSize = 20,
  }) =>
      _repository.searchProducts(
        search: search,
        page: page,
        pageSize: pageSize,
      );
}
