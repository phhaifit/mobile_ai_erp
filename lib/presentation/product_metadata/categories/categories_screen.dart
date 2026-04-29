import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/categories_screen_body.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_view_mode.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_filter_sheet.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_confirm_delete.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_reaction.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_sort_sheet.dart';

class ProductMetadataCategoriesScreen extends StatefulWidget {
  const ProductMetadataCategoriesScreen({super.key, this.args});
  final CategoriesArgs? args;
  @override
  State<ProductMetadataCategoriesScreen> createState() =>
      _ProductMetadataCategoriesScreenState();
}

class _ProductMetadataCategoriesScreenState
    extends State<ProductMetadataCategoriesScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  MetadataListQuery _queryState = const MetadataListQuery();
  CategoryStatus? _statusFilter;
  Timer? _searchDebounce;
  late List<ReactionDisposer> _disposers;
  late CategoryViewMode _viewMode;
  List<Category> _treePath = const <Category>[];
  int _refreshVersion = 0;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.args?.initialViewMode ?? CategoryViewMode.list;
    _treePath = widget.args?.initialTreePath ?? const <Category>[];
    _disposers = [createMetadataErrorReaction(context: context,
      errorMessage: () => _store.errorStore.errorMessage,
      isMounted: () => mounted, actionLabel: 'load categories')];
    Future<void>.microtask(_loadCategories);
  }

  @override
  void dispose() {
    for (final d in _disposers) { d(); }
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Categories'),
      actions: [IconButton(
        icon: const Icon(Icons.dashboard_outlined),
        onPressed: () => Navigator.of(context).popUntil(
          (r) => r.settings.name == ProductMetadataNavigator.productMetadataHomeRoute || r.isFirst),
      )],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _openCreateCategory,
      icon: const Icon(Icons.add),
      label: const Text('Add category'),
    ),
    body: CategoriesScreenBody(
      store: _store,
      viewMode: _viewMode,
      searchController: _searchController, queryState: _queryState,
      statusFilter: _statusFilter, hasActiveFilter: _statusFilter != null,
      onSearchChanged: _onSearchChanged,
      onSwitchView: _switchView,
      onOpenFilter: _openFilterSheet, onOpenSort: _openSortSheet,
      onPreviousPage: _previousPage, onNextPage: _nextPage,
      onDelete: _deleteCategory,
      onOpenTreeAt: _openTreeAt,
      onRefresh: _refreshActiveView,
      refreshVersion: _refreshVersion,
      initialTreePath: _treePath,
    ),
  );

  void _previousPage() { _setQuery(_queryState.copyWith(page: _store.categoryCurrentPage - 1)); _loadCategories(); }
  void _nextPage()     { _setQuery(_queryState.copyWith(page: _store.categoryCurrentPage + 1)); _loadCategories(); }

  Future<void> _openFilterSheet() async {
    final selected = await showCategoryFilterSheet(context, selectedStatus: _statusFilter);
    if (!mounted || selected == _statusFilter) return;
    setState(() { _statusFilter = selected; _queryState = _queryState.copyWith(page: 1); });
    if (_isListTab) await _loadCategories();
  }

  void _onSearchChanged(String value) {
    _setQuery(_queryState.copyWith(search: value.trim(), page: 1));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _loadCategories);
  }

  void _switchView() {
    _searchDebounce?.cancel();
    setState(() {
      _viewMode = _viewMode.toggled;
      _queryState = _queryState.copyWith(page: 1);
    });
    if (_isListTab) {
      _loadCategories();
    } else {
      setState(() => _refreshVersion++);
    }
  }

  void _openTreeAt(Category category) {
    if ((category.childrenCount ?? 0) <= 0) return;
    _searchDebounce?.cancel();
    setState(() {
      _viewMode = CategoryViewMode.tree;
      _treePath = <Category>[category];
      _queryState = _queryState.copyWith(page: 1);
      _refreshVersion++;
    });
  }

  void _openSortSheet() => showMetadataSortSheet(context, title: 'Sort categories',
    options: const [defaultMetadataSortOption],
    onSelected: (by, order) { _setQuery(_queryState.copyWith(sortBy: by, sortOrder: order, page: 1)); _loadCategories(); });

  void _deleteCategory(Category c) => deleteCategoryWithConfirm(context: context, category: c,
    currentTotalItems: _store.categoryTotalItems, queryState: _queryState,
    deleteFn: _store.deleteCategory, onQueryChanged: _setQuery,
    onReload: _loadCategories);

  Future<void> _openCreateCategory() async {
    final didChange = await ProductMetadataNavigator.openCategoryForm<bool>(
      context,
      args: const CategoryFormArgs(),
    );
    if (didChange == true) await _refreshActiveView();
  }

  Future<void> _refreshActiveView() async {
    if (_isListTab) {
      await _loadCategories();
      return;
    }
    if (mounted) setState(() => _refreshVersion++);
  }

  bool get _isListTab => _viewMode == CategoryViewMode.list;

  void _setQuery(MetadataListQuery q) { if (mounted) setState(() => _queryState = q); }

  Future<void> _loadCategories() => _store.loadCategories(
    page: _queryState.page, pageSize: _queryState.pageSize,
    search: _queryState.search, sortBy: _queryState.sortBy,
    sortOrder: _queryState.sortOrder, status: _statusFilter);
}
