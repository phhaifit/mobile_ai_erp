import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/data/local/datasources/cart/cart_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/cart/cart_local_datasource_impl.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/product/product_repository.dart';
import 'package:mobile_ai_erp/data/repository/product/product_repository_impl.dart';

/// Dependency Injection module for Cart data layer.
/// Registers CartDataSource, CartRepository, and mock ProductRepository
class CartDataModule {
  CartDataModule._();

  /// Setup cart data layer dependencies
  static void setup(GetIt getIt) {
    _setupDataSource(getIt);
    _setupRepository(getIt);
  }

  /// Register CartDataSource and its implementation
  static void _setupDataSource(GetIt getIt) {
    if (!getIt.isRegistered<CartDataSource>()) {
      getIt.registerSingleton<CartDataSource>(
        CartLocalDataSourceImpl(),
      );
    }
  }

  /// Register repositories and their implementations
  static void _setupRepository(GetIt getIt) {
    if (!getIt.isRegistered<CartRepository>()) {
      getIt.registerSingleton<CartRepository>(
        CartRepositoryImpl(
          dataSource: getIt<CartDataSource>(),
        ),
      );
    }

    /// Temporary mock ProductRepository
    /// Replace later when Product team delivers real implementation
    if (!getIt.isRegistered<ProductRepository>()) {
      getIt.registerSingleton<ProductRepository>(
        ProductRepositoryImpl(),
      );
    }
  }

  /// Reset/clear cart module from GetIt (useful for testing)
  static void reset(GetIt getIt) {
    if (getIt.isRegistered<CartRepository>()) {
      getIt.unregister<CartRepository>();
    }

    if (getIt.isRegistered<ProductRepository>()) {
      getIt.unregister<ProductRepository>();
    }

    if (getIt.isRegistered<CartDataSource>()) {
      getIt.unregister<CartDataSource>();
    }
  }

  /// Check if cart module is registered
  static bool isRegistered(GetIt getIt) {
    return getIt.isRegistered<CartRepository>() &&
        getIt.isRegistered<ProductRepository>() &&
        getIt.isRegistered<CartDataSource>();
  }
}
