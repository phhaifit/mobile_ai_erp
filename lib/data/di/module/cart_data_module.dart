import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/data/local/datasources/cart/cart_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/cart/cart_local_datasource_impl.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository_impl.dart';

/// Dependency Injection module for Cart data layer.
/// Registers CartDataSource and CartRepository implementations
class CartDataModule {
  CartDataModule._();

  /// Setup cart data layer dependencies
  static void setup(GetIt getIt) {
    // Register DataSource
    _setupDataSource(getIt);

    // Register Repository
    _setupRepository(getIt);
  }

  /// Register CartDataSource and its implementation
  static void _setupDataSource(GetIt getIt) {
    // Register mock implementation as singleton
    getIt.registerSingleton<CartDataSource>(
      CartLocalDataSourceImpl(),
    );
  }

  /// Register CartRepository and its implementation
  static void _setupRepository(GetIt getIt) {
    // Register repository as singleton
    // It depends on CartDataSource which is already registered
    getIt.registerSingleton<CartRepository>(
      CartRepositoryImpl(
        dataSource: getIt<CartDataSource>(),
      ),
    );
  }

  /// Reset/clear cart module from GetIt (useful for testing)
  static void reset(GetIt getIt) {
    if (getIt.isRegistered<CartRepository>()) {
      getIt.unregister<CartRepository>();
    }

    if (getIt.isRegistered<CartDataSource>()) {
      getIt.unregister<CartDataSource>();
    }
  }

  /// Check if cart module is registered
  static bool isRegistered(GetIt getIt) {
    return getIt.isRegistered<CartRepository>() &&
        getIt.isRegistered<CartDataSource>();
  }
}
