import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_list_item.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';

class CategoriesListTab extends StatelessWidget {
  const CategoriesListTab({
    super.key,
    required this.store,
    required this.searchQuery,
    required this.hasActiveFilter,
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onDelete,
    required this.onOpenTreeAt,
    required this.onRefresh,
  });

  final ProductMetadataStore store;
  final String searchQuery;
  final bool hasActiveFilter;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final void Function(Category category) onDelete;
  final ValueChanged<Category> onOpenTreeAt;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final items = store.categories.toList(growable: false);
    final hasActiveQuery = searchQuery.isNotEmpty || hasActiveFilter;

    if (items.isEmpty) {
      return MetadataEmptyState(
        icon: Icons.account_tree_outlined,
        title: hasActiveQuery ? 'No matching categories' : 'No categories yet',
        message: hasActiveQuery
            ? 'Try a different search keyword or filter.'
            : 'Add the first category to organize product metadata.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: items.length + (totalPages > 1 ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return MetadataPaginationControls(
            currentPage: currentPage,
            totalPages: totalPages,
            onPrevious: onPreviousPage,
            onNext: onNextPage,
          );
        }
        final item = items[index];
        return KeyedSubtree(
          key: ValueKey<String>(item.id),
          child: CategoryListItem(
            category: item,
            onDelete: () => onDelete(item),
            onDrillDown: () => onOpenTreeAt(item),
            onRefresh: onRefresh,
          ),
        );
      },
    );
  }
}
