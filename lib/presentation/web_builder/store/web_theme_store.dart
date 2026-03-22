import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/web_theme_list.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/apply_web_theme_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_web_theme_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_web_themes_usecase.dart';
import 'package:mobx/mobx.dart';

part 'web_theme_store.g.dart';

class WebThemeStore = _WebThemeStore with _$WebThemeStore;

abstract class _WebThemeStore with Store {
  // constructor:---------------------------------------------------------------
  _WebThemeStore(
    this._getWebThemesUseCase,
    this._getWebThemeByIdUseCase,
    this._applyWebThemeUseCase,
    this.errorStore,
  );

  // use cases:-----------------------------------------------------------------
  final GetWebThemesUseCase _getWebThemesUseCase;
  final GetWebThemeByIdUseCase _getWebThemeByIdUseCase;
  final ApplyWebThemeUseCase _applyWebThemeUseCase;

  // stores:--------------------------------------------------------------------
  final ErrorStore errorStore;

  // store variables:-----------------------------------------------------------
  static ObservableFuture<WebThemeList?> emptyResponse =
      ObservableFuture<WebThemeList?>.value(null);

  @observable
  ObservableFuture<WebThemeList?> fetchThemesFuture = emptyResponse;

  @observable
  WebThemeList? themeList;

  @observable
  WebTheme? selectedTheme;

  @observable
  bool success = false;

  @computed
  bool get loading => fetchThemesFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  Future getThemes() async {
    final future = _getWebThemesUseCase.call(params: null);
    fetchThemesFuture = ObservableFuture(future);

    future.then((themeList) {
      this.themeList = themeList;
    }).catchError((error) {
      errorStore.errorMessage = error.toString();
    });
  }

  @action
  Future getThemeById(String id) async {
    try {
      selectedTheme = await _getWebThemeByIdUseCase.call(params: id);
    } catch (error) {
      errorStore.errorMessage = error.toString();
    }
  }

  @action
  Future applyTheme(String id, {int? primaryColor, int? accentColor}) async {
    try {
      await _applyWebThemeUseCase.call(
        params: ApplyWebThemeParams(
          id: id,
          primaryColor: primaryColor,
          accentColor: accentColor,
        ),
      );
      success = true;
      await getThemes();
    } catch (error) {
      errorStore.errorMessage = error.toString();
    }
  }
}
