import 'package:mobile_ai_erp/core/domain/usecase/use_case.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/store_settings.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/store_settings_repository.dart';

class SaveStoreSettingsUseCase extends UseCase<void, StoreSettings> {
  final StoreSettingsRepository _repository;

  SaveStoreSettingsUseCase(this._repository);

  @override
  Future<void> call({required StoreSettings params}) {
    return _repository.saveSettings(params);
  }
}
