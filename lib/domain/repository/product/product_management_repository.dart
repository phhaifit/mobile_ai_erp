import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_filter.dart';
import 'package:mobile_ai_erp/domain/entity/shared/paginated_result.dart';

abstract class ProductManagementRepository {
  Future<List<Product>> getProducts();

  Future<PaginatedResult<Product>> getProductsPage({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  });

  Future<Product?> getProductById(int id);

  Future<int> createProduct(Product product);

  Future<int> updateProduct(Product product);

  Future<int> deleteProduct(int id);

  Future<List<Product>> searchProducts(ProductFilter filter);

  /// Saves a product by sending a POST request for new products or PATCH for updates
  Future<Product> saveProduct(Product product);
}
