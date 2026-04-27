import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/logic/metadata_pagination_logic.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_filter_sheet.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/categories_screen_body.dart';
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

class _ProductMetadataCategoriesScreenState extends State<ProductMetadataCategoriesScreen> with SingleTickerProviderStateMixin {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  MetadataListQuery _queryState = const MetadataListQuery();
  CategoryStatus? _statusFilter;
  late TabController _tabController;
  Timer? _searchDebounce;
  late List<ReactionDisposer> _disposers;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.args?.initialTabIndex ?? (widget.args?.parentCategoryId == null ? 0 : 1);
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() { if (_tabController.indexIsChanging) setState(() {}); });
    _disposers = [createMetadataErrorReaction(context: context, errorMessage: () => _store.errorStore.errorMessage, isMounted: () => mounted, actionLabel: 'load categories')];
    Future<void>.microtask(_loadCategoryPage);
  }

  @override
  void dispose() {
    for (final d in _disposers) { d(); }
    _searchDebounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parentId = widget.args?.parentCategoryId;
    return Scaffold(
      appBar: AppBar(
        title: Observer(builder: (_) {
          final tree = _store.categoryTree;
          final title = _tabController.index == 0
              ? 'Categories'
              : tree.where((c) => c.id == parentId).firstOrNull?.name ?? 'Categories Tree';
          return Text(title);
        }),
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'List'), Tab(text: 'Tree')]),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).popUntil(
              (r) => r.settings.name == ProductMetadataNavigator.productMetadataHomeRoute || r.isFirst,
            ),
            icon: const Icon(Icons.dashboard_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ProductMetadataNavigator.openCategoryForm(context,
            args: CategoryFormArgs(initialParentId: _tabController.index == 1 ? parentId : null)),
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 1 && parentId != null ? 'Add subcategory' : 'Add category'),
      ),
      body: CategoriesScreenBody(
        store: _store,
        tabController: _tabController,
        searchController: _searchController,
        queryState: _queryState,
        parentId: parentId,
        hasActiveFilter: _statusFilter != null,
        onSearchChanged: _onSearchChanged,
        onOpenFilter: _openFilterSheet,
        onOpenSort: _openSortSheet,
        onPreviousPage: _previousPage,
        onNextPage: _nextPage,
        onDelete: _deleteCategory,
        onReloadTree: _loadCategoryPage,
      ),
    );
  }
  void _previousPage() { _setQuery(_queryState.copyWith(page: _store.categoryCurrentPage - 1)); _loadCategories(); }
  void _nextPage() { _setQuery(_queryState.copyWith(page: _store.categoryCurrentPage + 1)); _loadCategories(); }

  Future<void> _openFilterSheet() async {
    final selected = await showCategoryFilterSheet(context, selectedStatus: _statusFilter);
    if (!mounted || selected == _statusFilter) return;
    setState(() { _statusFilter = selected; _queryState = _queryState.copyWith(page: 1); });
    await _loadCategoryPage();
  }

  void _onSearchChanged(String value) {
    _setQuery(_queryState.copyWith(search: value.trim(), page: 1));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _loadCategories);
  }

  void _openSortSheet() => showMetadataSortSheet(context,
    title: 'Sort categories',
    options: const [defaultMetadataSortOption],
    onSelected: (by, order) { _setQuery(_queryState.copyWith(sortBy: by, sortOrder: order, page: 1)); _loadCategories(); },
  );

  Future<void> _deleteCategory(Category category) async {
    final hasChildren = _store.categoryTree.any((c) => c.parentId == category.id);
    if (hasChildren) {
      await showMetadataDeleteDialog(context, title: 'Can\'t delete category', message: 'Remove or move the child categories under "${category.name}" first.', confirmLabel: 'Got it');
      return;
    }
    final confirmed = await showMetadataDeleteDialog(context, title: 'Delete category?', message: 'Delete "${category.name}"? This can\'t be undone.');
    if (!confirmed) return;
    final prev = _store.categoryTotalItems;
    await _store.deleteCategory(category.id);
    _setQuery(_queryState.copyWith(page: resolveMetadataPageAfterDelete(currentPage: _queryState.page, pageSize: _queryState.pageSize, totalItems: prev)));
    await _loadCategoryPage();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${category.name}".')));
  }

  void _setQuery(MetadataListQuery q) { if (mounted) setState(() => _queryState = q); }

  Future<void> _loadCategoryPage() => Future.wait([_loadCategories(), _store.loadCategoryTree(status: _statusFilter)]);
  Future<void> _loadCategories() => _store.loadCategories(page: _queryState.page, pageSize: _queryState.pageSize, search: _queryState.search, sortBy: _queryState.sortBy, sortOrder: _queryState.sortOrder, status: _statusFilter);
}
