import 'package:mobile_ai_erp/domain/di/module/usecase_module.dart';

class DomainLayerInjection {
  static Future<void> configureDomainLayerInjection() async {
    await UseCaseModule.configureUseCaseModuleInjection();
  }
}
