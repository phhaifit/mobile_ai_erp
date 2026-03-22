import 'package:get_it/get_it.dart' show GetIt;
import 'package:mobile_ai_erp/core/stores/supplier/supplier_store.dart';
import 'package:mobile_ai_erp/data/supplier/supplier_mock_repository.dart';
import 'package:mobile_ai_erp/domain/supplier/supplier_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  registerSupplierDependencies(getIt);
}

void registerSupplierDependencies(GetIt getIt) {
  getIt.registerLazySingleton<SupplierRepository>(
    () => SupplierMockRepository(),
  );

  getIt.registerLazySingleton<SupplierStore>(
    () => SupplierStore(getIt<SupplierRepository>()),
  );
}
