import 'package:mobile_ai_erp/data/di/data_layer_injection.dart';
import 'package:mobile_ai_erp/data/di/module/cart_data_module.dart';
import 'package:mobile_ai_erp/data/di/module/customer_data_module.dart';
import 'package:mobile_ai_erp/domain/di/domain_layer_injection.dart';
import 'package:mobile_ai_erp/presentation/di/module/store_module.dart';
import 'package:mobile_ai_erp/presentation/customer/di/customer_presentation_di.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> configureDependencies({String? userId}) async {
    await DataLayerInjection.configureDataLayerInjection();
    CartDataModule.setup(getIt);
    CustomerDataModule.setup(getIt);
    CustomerPresentationDi.setup(getIt);
    await DomainLayerInjection.configureDomainLayerInjection();
    await StoreModule.configureStoreModuleInjection();
  }
}
