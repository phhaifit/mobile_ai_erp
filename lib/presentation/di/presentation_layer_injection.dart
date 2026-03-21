import 'package:mobile_ai_erp/presentation/cart/di/cart_presentation_module.dart';
import 'package:mobile_ai_erp/presentation/di/module/store_module.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/presentation/product/di/product_injection.dart';

class PresentationLayerInjection {
  static Future<void> configurePresentationLayerInjection(
      {String? userId}) async {
    await StoreModule.configureStoreModuleInjection();

    CartPresentationModule.setup(
      GetIt.instance,
      userId: userId ?? 'mock_user_001',
    );
    await ProductInjection.configureProductInjection();
  }
}
