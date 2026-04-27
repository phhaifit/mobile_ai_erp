import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/create_tag_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/delete_tag_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/get_tags_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/update_tag_usecase.dart';
import 'package:mobx/mobx.dart';

part 'tag_store.g.dart';

class TagStore = TagStoreBase with _$TagStore;

abstract class TagStoreBase with Store {
  TagStoreBase({
    required GetTagsUseCase getTagsUseCase,
    required CreateTagUseCase createTagUseCase,
    required UpdateTagUseCase updateTagUseCase,
    required DeleteTagUseCase deleteTagUseCase,
    required this.errorStore,
  })  : _getTagsUseCase = getTagsUseCase,
        _createTagUseCase = createTagUseCase,
        _updateTagUseCase = updateTagUseCase,
        _deleteTagUseCase = deleteTagUseCase;

  final GetTagsUseCase _getTagsUseCase;
  final CreateTagUseCase _createTagUseCase;
  final UpdateTagUseCase _updateTagUseCase;
  final DeleteTagUseCase _deleteTagUseCase;

  final ErrorStore errorStore;

  @observable
  ObservableList<Tag> tags = ObservableList<Tag>();

  @observable
  int currentPage = 1;

  @observable
  int pageSize = 10;

  @observable
  int totalItems = 0;

  @observable
  int totalPages = 0;

  @observable
  bool isLoading = false;

  @observable
  String? error;

  @observable
  String? searchQuery;

  @observable
  String? sortBy;

  @observable
  String? sortOrder;

  @action
  Future<void> loadTags({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    await _runWithLoading(() async {
      try {
        final result = await _getTagsUseCase.call(
          params: GetTagsParams(
            page: page,
            pageSize: pageSize,
            search: search,
            sortBy: sortBy,
            sortOrder: sortOrder,
          ),
        );
        _applyMetadataPage(result);
        searchQuery = search;
        this.sortBy = sortBy;
        this.sortOrder = sortOrder;
        error = null;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  @action
  Future<Tag> createTag(Tag tag) async {
    return await _runWithLoading(() async {
      try {
        final result = await _createTagUseCase.call(params: tag);
        await _reloadCurrentQuery();
        error = null;
        return result;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  @action
  Future<Tag> updateTag(Tag tag) async {
    return await _runWithLoading(() async {
      try {
        final result = await _updateTagUseCase.call(params: tag);
        await _reloadCurrentQuery();
        error = null;
        return result;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  @action
  Future<void> deleteTag(String tagId) async {
    await _runWithLoading(() async {
      try {
        await _deleteTagUseCase.call(params: tagId);
        await _reloadCurrentQuery();
        error = null;
      } catch (e) {
        error = e.toString();
        errorStore.setErrorMessage(e.toString());
        rethrow;
      }
    });
  }

  int _loadingOperations = 0;

  @action
  void _beginLoadingOperation() {
    _loadingOperations++;
    isLoading = _loadingOperations > 0;
  }

  @action
  void _endLoadingOperation() {
    if (_loadingOperations > 0) {
      _loadingOperations--;
    }
    isLoading = _loadingOperations > 0;
  }

  Future<T> _runWithLoading<T>(Future<T> Function() fn) async {
    _beginLoadingOperation();
    try {
      return await fn();
    } finally {
      _endLoadingOperation();
    }
  }

  Future<void> _reloadCurrentQuery() async {
    await _runWithLoading(() async {
      final result = await _getTagsUseCase.call(
        params: GetTagsParams(
          page: currentPage,
          pageSize: pageSize,
          search: searchQuery,
          sortBy: sortBy,
          sortOrder: sortOrder,
        ),
      );
      _applyMetadataPage(result);
    });
  }

  @action
  void _applyMetadataPage(MetadataPage<Tag> page) {
    tags = ObservableList.of(page.items);
    currentPage = page.page;
    pageSize = page.pageSize;
    totalItems = page.totalItems;
    totalPages = page.totalPages;
  }
}
