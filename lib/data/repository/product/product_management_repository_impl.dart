import 'dart:async';

import 'package:mobile_ai_erp/data/local/datasources/product/mock_product_datasource.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_filter.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_management_repository.dart';

class ProductManagementRepositoryImpl extends ProductManagementRepository {
  // datasource instance
  final MockProductDataSource _dataSource;

  // constructor
  ProductManagementRepositoryImpl(this._dataSource);

  @override
  Future<List<Product>> getProducts() async {
    try {
      return await _dataSource.getProducts();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Product?> getProductById(int id) async {
    try {
      return await _dataSource.getProductById(id);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<int> createProduct(Product product) async {
    try {
      return await _dataSource.createProduct(product);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<int> updateProduct(Product product) async {
    try {
      return await _dataSource.updateProduct(product);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<int> deleteProduct(int id) async {
    try {
      return await _dataSource.deleteProduct(id);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> searchProducts(ProductFilter filter) async {
    try {
      final allProducts = await _dataSource.getProducts();
      
      // Apply filter
      final filtered = allProducts.where((product) {
        return filter.matches(product.toMap());
      }).toList();

      return filtered;
    } catch (error) {
      rethrow;
    }
  }
}
