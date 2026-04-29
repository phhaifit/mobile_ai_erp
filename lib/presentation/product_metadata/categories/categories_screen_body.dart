import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/categories_list_tab.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/categories_tree_tab.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_view_mode.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_layout.dart';

class CategoriesScreenBody extends StatelessWidget {
  const CategoriesScreenBody({
    super.key,
    required this.store,
    required this.viewMode,
    required this.searchController,
    required this.queryState,
    required this.statusFilter,
    required this.hasActiveFilter,
    required this.onSearchChanged,
    required this.onSwitchView,
    required this.onOpenFilter,
    required this.onOpenSort,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onDelete,
    required this.onOpenTreeAt,
    required this.onRefresh,
    required this.refreshVersion,
    required this.initialTreePath,
  });

  final ProductMetadataStore store;
  final CategoryViewMode viewMode;
  final TextEditingController searchController;
  final MetadataListQuery queryState;
  final CategoryStatus? statusFilter;
  final bool hasActiveFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSwitchView;
  final VoidCallback onOpenFilter;
  final VoidCallback onOpenSort;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final void Function(Category) onDelete;
  final ValueChanged<Category> onOpenTreeAt;
  final VoidCallback onRefresh;
  final int refreshVersion;
  final List<Category> initialTreePath;

  @override
  Widget build(BuildContext context) {
    if (viewMode == CategoryViewMode.tree) {
      return CategoriesTreeTab(
        store: store,
        queryState: queryState,
        searchController: searchController,
        statusFilter: statusFilter,
        onOpenFilter: onOpenFilter,
        onOpenSort: onOpenSort,
        onSearchChanged: onSearchChanged,
        onSwitchView: onSwitchView,
        refreshVersion: refreshVersion,
        initialPath: initialTreePath,
      );
    }
    return Observer(
      builder: (_) => MetadataListLayout(
                  isLoading: store.isCategoryLoading,
                  controls: MetadataListControls(
                    searchController: searchController,
                    onSearchChanged: onSearchChanged,
                    searchHint: 'Search by name, slug, or description',
                    resultLabel: 'Showing ${store.categories.length} of ${store.categoryTotalItems} categories',
                    hasActiveFilter: hasActiveFilter,
                    hasCustomSort: queryState.hasCustomSort,
                    viewSwitchIcon: viewMode.switchIcon,
                    viewSwitchTooltip: viewMode.switchTooltip,
                    onSwitchView: onSwitchView,
                    onOpenFilter: onOpenFilter,
                    onOpenSort: onOpenSort,
                  ),
                  child: CategoriesListTab(
                    store: store,
                    searchQuery: queryState.search,
                    hasActiveFilter: hasActiveFilter,
                    currentPage: store.categoryCurrentPage,
                    totalPages: store.categoryTotalPages,
                    onPreviousPage: store.categoryCurrentPage > 1 ? onPreviousPage : null,
                    onNextPage: store.categoryCurrentPage < store.categoryTotalPages ? onNextPage : null,
                    onDelete: onDelete,
                    onOpenTreeAt: onOpenTreeAt,
                    onRefresh: onRefresh,
                  ),
                ),
    );
  }
}
