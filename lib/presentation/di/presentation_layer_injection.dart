import 'package:mobile_ai_erp/presentation/di/module/store_module.dart';
import 'package:mobile_ai_erp/presentation/di/module/user_store_module.dart';

class PresentationLayerInjection {
  static Future<void> configurePresentationLayerInjection() async {
    await StoreModule.configureStoreModuleInjection();
    await UserStoreModule.configureStoreModuleInjection();
  }
}
