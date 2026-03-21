import 'package:mobile_ai_erp/data/datasources/product/mock_product_datasource.dart';
import 'package:mobile_ai_erp/data/repository/product/product_management_repository_impl.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_management_repository.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_form_store.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_store.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/core/stores/error/error_store.dart';

final getIt = GetIt.instance;

class ProductInjection {
  static Future<void> configureProductInjection() async {
    // Register datasources
    getIt.registerSingleton<MockProductDataSource>(
      MockProductDataSource(),
    );

    // Register repositories
    getIt.registerSingleton<ProductManagementRepository>(
      ProductManagementRepositoryImpl(getIt<MockProductDataSource>()),
    );

    // Register stores
    getIt.registerSingleton<ProductStore>(
      ProductStore(getIt<ProductManagementRepository>(), getIt<ErrorStore>()),
    );

    getIt.registerSingleton<ProductFormStore>(
      ProductFormStore(getIt<ProductManagementRepository>(), getIt<ErrorStore>()),
    );
  }
}
