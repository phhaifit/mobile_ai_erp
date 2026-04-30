import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page.dart';
import 'package:mobile_ai_erp/domain/entity/web_builder/cms_page_list.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/delete_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_cms_page_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_cms_pages_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/publish_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/save_cms_page_usecase.dart';
import 'package:mobx/mobx.dart';

part 'cms_page_store.g.dart';

class CmsPageStore = _CmsPageStore with _$CmsPageStore;

abstract class _CmsPageStore with Store {
  // constructor:---------------------------------------------------------------
  _CmsPageStore(
    this._getCmsPagesUseCase,
    this._getCmsPageByIdUseCase,
    this._saveCmsPageUseCase,
    this._deleteCmsPageUseCase,
    this._publishCmsPageUseCase,
    this.errorStore,
  );

  // use cases:-----------------------------------------------------------------
  final GetCmsPagesUseCase _getCmsPagesUseCase;
  final GetCmsPageByIdUseCase _getCmsPageByIdUseCase;
  final SaveCmsPageUseCase _saveCmsPageUseCase;
  final DeleteCmsPageUseCase _deleteCmsPageUseCase;
  final PublishCmsPageUseCase _publishCmsPageUseCase;

  // stores:--------------------------------------------------------------------
  final ErrorStore errorStore;

  // store variables:-----------------------------------------------------------
  static ObservableFuture<CmsPageList?> emptyResponse =
      ObservableFuture<CmsPageList?>.value(null);

  @observable
  ObservableFuture<CmsPageList?> fetchPagesFuture = emptyResponse;

  @observable
  CmsPageList? pageList;

  @observable
  CmsPage? selectedPage;

  @observable
  bool success = false;

  @computed
  bool get loading => fetchPagesFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  Future getPages() async {
    final future = _getCmsPagesUseCase.call(params: null);
    fetchPagesFuture = ObservableFuture(future);

    future.then((pageList) {
      this.pageList = pageList;
    }).catchError((error) {
      errorStore.errorMessage = error.toString();
    });
  }

  @action
  Future getPageById(String id) async {
    try {
      selectedPage = await _getCmsPageByIdUseCase.call(params: id);
    } catch (error) {
      errorStore.errorMessage = error.toString();
    }
  }

  @action
  Future savePage(CmsPage page) async {
    try {
      await _saveCmsPageUseCase.call(params: page);
      success = true;
      await getPages();
    } catch (error) {
      errorStore.errorMessage = error.toString();
    }
  }

  @action
  Future deletePage(String id) async {
    try {
      await _deleteCmsPageUseCase.call(params: id);
      success = true;
      await getPages();
    } catch (error) {
      errorStore.errorMessage = error.toString();
    }
  }

  @action
  Future publishPage(String id, bool published) async {
    try {
      await _publishCmsPageUseCase.call(
        params: PublishCmsPageParams(id: id, published: published),
      );
      success = true;
      await getPages();
    } catch (error) {
      errorStore.errorMessage = error.toString();
    }
  }
}
