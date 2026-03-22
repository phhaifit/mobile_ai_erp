import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/store_settings.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_store_settings_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/save_store_settings_usecase.dart';
import 'package:mobx/mobx.dart';

part 'store_settings_store.g.dart';

class StoreSettingsStore = _StoreSettingsStore with _$StoreSettingsStore;

abstract class _StoreSettingsStore with Store {
  // constructor:---------------------------------------------------------------
  _StoreSettingsStore(
    this._getStoreSettingsUseCase,
    this._saveStoreSettingsUseCase,
    this.errorStore,
  );

  // use cases:-----------------------------------------------------------------
  final GetStoreSettingsUseCase _getStoreSettingsUseCase;
  final SaveStoreSettingsUseCase _saveStoreSettingsUseCase;

  // stores:--------------------------------------------------------------------
  final ErrorStore errorStore;

  // store variables:-----------------------------------------------------------
  static ObservableFuture<StoreSettings?> emptyResponse =
      ObservableFuture<StoreSettings?>.value(null);

  @observable
  ObservableFuture<StoreSettings?> fetchSettingsFuture = emptyResponse;

  @observable
  StoreSettings? settings;

  @observable
  bool success = false;

  @computed
  bool get loading => fetchSettingsFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  Future getSettings() async {
    final future = _getStoreSettingsUseCase.call(params: null);
    fetchSettingsFuture = ObservableFuture(future);

    future.then((settings) {
      this.settings = settings;
    }).catchError((error) {
      errorStore.errorMessage = error.toString();
    });
  }

  @action
  Future saveSettings(StoreSettings settings) async {
    try {
      await _saveStoreSettingsUseCase.call(params: settings);
      success = true;
      this.settings = settings;
    } catch (error) {
      errorStore.errorMessage = error.toString();
    }
  }
}
