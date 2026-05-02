import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/domain/repository/customer_auth_repository.dart';
import 'package:mobile_ai_erp/presentation/customer/store/subdomain_store.dart';

final getIt = GetIt.instance;

class CustomerPresentationDi {
  CustomerPresentationDi._();

  /// Setup cart presentation layer dependencies
  static void setup(GetIt getIt) {
  // Stores
  // getIt.registerSingleton<AuthStore>(
  //   AuthStore(
  //     repository: getIt<CustomerAuthRepository>(),
  //   ),
  // );

  // Register SubdomainStore with preferences
  getIt.registerSingleton<SubdomainStore>(
    SubdomainStore(
      authRepository: getIt<CustomerAuthRepository>(),
      preferences: getIt(),
    ),
  );
  }
}