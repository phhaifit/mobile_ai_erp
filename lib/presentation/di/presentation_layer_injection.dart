import 'package:mobile_ai_erp/presentation/cart/di/cart_presentation_module.dart';
import 'package:mobile_ai_erp/presentation/di/module/store_module.dart';
import 'package:get_it/get_it.dart';

class PresentationLayerInjection {
  static Future<void> configurePresentationLayerInjection(
      {String? userId}) async {
    await StoreModule.configureStoreModuleInjection();

    CartPresentationModule.setup(
      GetIt.instance,
      userId: userId ?? 'mock_user_001',
    );
  }
}
