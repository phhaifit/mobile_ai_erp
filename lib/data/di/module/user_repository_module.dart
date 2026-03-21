import 'package:mobile_ai_erp/data/local/datasources/user/role_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/user/user_datasource.dart';
import 'package:mobile_ai_erp/data/repository/user/role_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/user/user_repository_impl.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';

class UserRepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    // datasource:--------------------------------------------------------------
    getIt.registerSingleton<UserDataSource>(UserDataSource());
    getIt.registerSingleton<RoleDataSource>(RoleDataSource());

    getIt.registerSingleton<UserRepository>(
        UserRepositoryImpl(getIt<UserDataSource>()));

    getIt.registerSingleton<RoleRepository>(
        RoleRepositoryImpl(getIt<RoleDataSource>()));
  }
}
