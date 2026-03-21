import 'package:mobile_ai_erp/data/di/module/local_module.dart';
import 'package:mobile_ai_erp/data/di/module/network_module.dart';
import 'package:mobile_ai_erp/data/di/module/repository_module.dart';
import 'package:mobile_ai_erp/data/di/module/user_repository_module.dart';

class DataLayerInjection {
  static Future<void> configureDataLayerInjection() async {
    await LocalModule.configureLocalModuleInjection();
    await NetworkModule.configureNetworkModuleInjection();
    await RepositoryModule.configureRepositoryModuleInjection();
    await UserRepositoryModule.configureRepositoryModuleInjection();
  }
}
