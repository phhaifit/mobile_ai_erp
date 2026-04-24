import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/data/network/apis/suppliers/supplier_api.dart';
import 'package:mobile_ai_erp/data/network/dto/suppliers/product_supplier_link.dto.dart';
import 'package:mobile_ai_erp/data/network/mappers/suppliers/product_supplier_mapper.dart';
import 'package:mobile_ai_erp/data/network/mappers/suppliers/supplier_mapper.dart';
import 'package:mobile_ai_erp/domain/entity/shared/paginated_result.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/product_summary.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/supplier.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/supplier_product_link.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/supplier_upsert_payload.dart';
import 'package:mobile_ai_erp/domain/repository/supplier/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierApi _api;

  SupplierRepositoryImpl(this._api);

  @override
  Future<PaginatedResult<Supplier>> getSuppliers({
    String search = '',
    int page = 1,
    int pageSize = 10,
    bool? hasProducts,
    String? sortBy,
    String? sortOrder,
  }) async {
    final response = await _api.getSuppliers(
      search: search,
      page: page,
      pageSize: pageSize,
      hasProducts: hasProducts,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
    final data = response['data'] as List<dynamic>;
    final meta = response['meta'] as Map<String, dynamic>;
    return PaginatedResult(
      data: SupplierMapper.fromJsonList(data),
      page: meta['page'] as int,
      pageSize: meta['pageSize'] as int,
      totalItems: meta['totalItems'] as int,
      totalPages: meta['totalPages'] as int,
    );
  }

  @override
  Future<Supplier?> getById(String id) async {
    try {
      final response = await _api.getSupplierById(id);
      return SupplierMapper.fromJson(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Supplier> add(SupplierUpsertPayload payload) async {
    final response = await _api.createSupplier(payload.toJson());
    return SupplierMapper.fromJson(response);
  }

  @override
  Future<Supplier> update(String id, SupplierUpsertPayload payload) async {
    final response = await _api.updateSupplier(id, payload.toJson());
    return SupplierMapper.fromJson(response);
  }

  @override
  Future<void> delete(String id) async {
    await _api.deleteSupplier(id);
  }

  @override
  Future<PaginatedResult<SupplierProductLink>> getSupplierProducts(
    String supplierId, {
    int page = 1,
    int pageSize = 10,
    String search = '',
  }) async {
    final response = await _api.getSupplierProducts(
      supplierId,
      page: page,
      pageSize: pageSize,
      search: search,
    );
    final data = response['data'] as List<dynamic>;
    final meta = response['meta'] as Map<String, dynamic>?;
    return PaginatedResult(
      data: ProductSupplierMapper.fromJsonList(data),
      page: meta?['page'] as int? ?? page,
      pageSize: meta?['pageSize'] as int? ?? pageSize,
      totalItems: meta?['totalItems'] as int? ?? data.length,
      totalPages: meta?['totalPages'] as int? ?? 1,
    );
  }

  @override
  Future<void> addProductToSupplier(
    String productId,
    String supplierId, {
    String? supplierSku,
    double? costPrice,
    bool isPrimary = false,
  }) async {
    final dto = AddProductSupplierRequestDto(
      supplierId: supplierId,
      supplierSku: supplierSku,
      costPrice: costPrice,
      isPrimary: isPrimary,
    );
    await _api.addProductToSupplier(productId, dto.toJson());
  }

  @override
  Future<void> updateProductSupplierLink(
    String productId,
    String supplierId, {
    String? supplierSku,
    double? costPrice,
    bool? isPrimary,
  }) async {
    final dto = UpdateProductSupplierRequestDto(
      supplierSku: supplierSku,
      costPrice: costPrice,
      isPrimary: isPrimary,
    );
    await _api.updateProductSupplier(productId, supplierId, dto.toJson());
  }

  @override
  Future<void> removeProductFromSupplier(
    String productId,
    String supplierId,
  ) async {
    await _api.removeProductFromSupplier(productId, supplierId);
  }

  @override
  Future<PaginatedResult<ProductSummary>> searchProducts({
    String search = '',
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _api.searchProducts(
      search: search,
      page: page,
      pageSize: pageSize,
    );
  }
}
