import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/presentation/user/store/role_store.dart';
import 'package:mobile_ai_erp/presentation/user/store/user_store.dart';

class UserStoreModule {
  static Future<void> configureStoreModuleInjection() async {
    getIt.registerSingleton<UserStore>(
        UserStore(getIt<UserRepository>(), getIt<RoleRepository>()));

    getIt.registerSingleton<RoleStore>(RoleStore(getIt<RoleRepository>()));
  }
}
