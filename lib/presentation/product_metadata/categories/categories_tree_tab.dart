import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/categories_list_view.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_view_mode.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/categories_level_header.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_confirm_delete.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_loading_overlay.dart';

class CategoriesTreeTab extends StatefulWidget {
  const CategoriesTreeTab({
    super.key,
    required this.store,
    required this.queryState,
    required this.searchController,
    required this.statusFilter,
    required this.onOpenFilter,
    required this.onOpenSort,
    required this.onSearchChanged,
    required this.onSwitchView,
    required this.refreshVersion,
    required this.initialPath,
  });

  final ProductMetadataStore store;
  final MetadataListQuery queryState;
  final TextEditingController searchController;
  final CategoryStatus? statusFilter;
  final VoidCallback onOpenFilter;
  final VoidCallback onOpenSort;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSwitchView;
  final int refreshVersion;
  final List<Category> initialPath;

  @override
  State<CategoriesTreeTab> createState() => _CategoriesTreeTabState();
}

class _CategoriesTreeTabState extends State<CategoriesTreeTab>
    with AutomaticKeepAliveClientMixin {
  List<Category> _items = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalItems = 0;
  String? _currentParentId;
  List<Category> _breadcrumbPath = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _breadcrumbPath = widget.initialPath;
    _currentParentId = _breadcrumbPath.isEmpty ? null : _breadcrumbPath.last.id;
    Future<void>.microtask(_load);
  }

  @override
  void didUpdateWidget(CategoriesTreeTab old) {
    super.didUpdateWidget(old);
    if (old.statusFilter != widget.statusFilter ||
        old.queryState.search != widget.queryState.search ||
        old.queryState.sortBy != widget.queryState.sortBy ||
        old.queryState.sortOrder != widget.queryState.sortOrder) {
      _load();
    }
    if (old.refreshVersion != widget.refreshVersion) _load(page: _currentPage);
  }

  Future<void> _load({int page = 1}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final result = await widget.store.fetchCategoriesPage(page: page, pageSize: 10,
        search: widget.queryState.search.isEmpty ? null : widget.queryState.search,
        sortBy: widget.queryState.sortBy, sortOrder: widget.queryState.sortOrder,
        status: widget.statusFilter,
        parentId: _currentParentId, rootOnly: _currentParentId == null);
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _currentPage = result.page;
        _totalPages = result.totalPages;
        _totalItems = result.totalItems;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _drillDown(Category parent) {
    setState(() {
      _breadcrumbPath = [..._breadcrumbPath, parent];
      _currentParentId = parent.id; _currentPage = 1;
    });
    _load();
  }

  void _navigateToLevel(String? targetParentId) {
    if (targetParentId == _currentParentId) return;
    if (targetParentId == null) {
      setState(() { _breadcrumbPath = []; _currentParentId = null; _currentPage = 1; });
    } else {
      final i = _breadcrumbPath.indexWhere((c) => c.id == targetParentId);
      if (i < 0) return;
      setState(() {
        _breadcrumbPath = _breadcrumbPath.sublist(0, i + 1);
        _currentParentId = targetParentId; _currentPage = 1;
      });
    }
    _load();
  }

  Future<void> _delete(Category category) => deleteCategoryWithConfirm(
    context: context, category: category,
    currentTotalItems: _items.length, queryState: const MetadataListQuery(),
    deleteFn: (_) => widget.store.deleteCategory(category.id),
    onQueryChanged: (_) {},
    onReload: () => _load(page: _currentPage),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: CategoriesLevelHeader(
            path: _breadcrumbPath,
            onNavigateToLevel: _navigateToLevel,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: MetadataListControls(
            searchController: widget.searchController,
            onSearchChanged: widget.onSearchChanged,
            searchHint: 'Search by name, slug, or description in this level',
            resultLabel: 'Showing ${_items.length} of $_totalItems categories',
            hasActiveFilter: widget.statusFilter != null,
            hasCustomSort: widget.queryState.hasCustomSort,
            viewSwitchIcon: CategoryViewMode.tree.switchIcon,
            viewSwitchTooltip: CategoryViewMode.tree.switchTooltip,
            onSwitchView: widget.onSwitchView,
            onOpenFilter: widget.onOpenFilter,
            onOpenSort: widget.onOpenSort,
          ),
        ),
        Expanded(
          child: MetadataLoadingOverlay(
            isLoading: _isLoading,
            child: _buildList(),
          ),
        ),
      ],
    );
  }

  Widget _buildList() => CategoriesListView(
    items: _items,
    isLoading: _isLoading,
    parentId: _currentParentId,
    currentPage: _currentPage,
    totalPages: _totalPages,
    onPreviousPage: () => _load(page: _currentPage - 1),
    onNextPage: () => _load(page: _currentPage + 1),
    onDelete: _delete,
    onDrillDown: _drillDown,
    onRefresh: () => _load(page: _currentPage),
  );
}
