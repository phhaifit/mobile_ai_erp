import 'package:mobile_ai_erp/presentation/cart/di/cart_presentation_module.dart';
import 'package:mobile_ai_erp/presentation/customer/di/customer_presentation_di.dart';
import 'package:mobile_ai_erp/presentation/di/module/store_module.dart';
import 'package:get_it/get_it.dart';

class PresentationLayerInjection {
  static Future<void> configurePresentationLayerInjection(
      {String? userId}) async {
    // Register CartStore first since CheckoutStore depends on it
    CartPresentationModule.setup(
      GetIt.instance,
      userId: userId ?? 'mock_user_001',
    );

    CustomerPresentationDi.setup(getIt);

    // Then register other stores (including CheckoutStore which needs CartStore)
    await StoreModule.configureStoreModuleInjection();
  }
}
