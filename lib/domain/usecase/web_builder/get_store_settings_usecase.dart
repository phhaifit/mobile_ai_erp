import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/store_settings.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/store_settings_repository.dart';

class GetStoreSettingsUseCase extends UseCase<StoreSettings, void> {
  final StoreSettingsRepository _repository;

  GetStoreSettingsUseCase(this._repository);

  @override
  Future<StoreSettings> call({required params}) {
    return _repository.getSettings();
  }
}
