import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_filter.dart';

abstract class ProductManagementRepository {
  Future<List<Product>> getProducts();

  Future<Product?> getProductById(int id);

  Future<int> createProduct(Product product);

  Future<int> updateProduct(Product product);

  Future<int> deleteProduct(int id);

  Future<List<Product>> searchProducts(ProductFilter filter);
}
