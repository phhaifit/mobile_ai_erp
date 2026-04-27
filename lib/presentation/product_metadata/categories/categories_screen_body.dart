import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/categories_list_tab.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/categories_tree_tab.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_loading_overlay.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_layout.dart';

class CategoriesScreenBody extends StatelessWidget {
  const CategoriesScreenBody({
    super.key,
    required this.store,
    required this.tabController,
    required this.searchController,
    required this.queryState,
    required this.parentId,
    required this.hasActiveFilter,
    required this.onSearchChanged,
    required this.onOpenFilter,
    required this.onOpenSort,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onDelete,
    required this.onReloadTree,
  });

  final ProductMetadataStore store;
  final TabController tabController;
  final TextEditingController searchController;
  final MetadataListQuery queryState;
  final String? parentId;
  final bool hasActiveFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilter;
  final VoidCallback onOpenSort;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final ValueChanged<Category> onDelete;
  final Future<void> Function() onReloadTree;

  @override
  Widget build(BuildContext context) => Observer(
    builder: (context) => TabBarView(
      controller: tabController,
      children: [
        MetadataListLayout(
          isLoading: store.isCategoryLoading,
          controls: MetadataListControls(
            searchController: searchController,
            onSearchChanged: onSearchChanged,
            searchHint: 'Search by name, slug, or description',
            resultLabel: 'Showing ${store.categories.length} of ${store.categoryTotalItems} categories',
            hasActiveFilter: hasActiveFilter,
            hasCustomSort: queryState.hasCustomSort,
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
          ),
        ),
        MetadataLoadingOverlay(
          isLoading: store.isCategoryLoading,
          child: CategoriesTreeTab(
            store: store,
            parentId: parentId,
            hasActiveFilter: hasActiveFilter,
            onDelete: onDelete,
            onOpenFilter: onOpenFilter,
            onReload: onReloadTree,
          ),
        ),
      ],
    ),
  );
}
