import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_list_item.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';

class CategoriesListView extends StatelessWidget {
  const CategoriesListView({
    super.key,
    required this.items,
    required this.isLoading,
    required this.parentId,
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onDelete,
    required this.onDrillDown,
    required this.onRefresh,
  });

  final List<Category> items;
  final bool isLoading;
  final String? parentId;
  final int currentPage;
  final int totalPages;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final Future<void> Function(Category) onDelete;
  final void Function(Category) onDrillDown;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoading) {
      return MetadataEmptyState(
        icon: parentId == null ? Icons.account_tree_outlined : Icons.folder_open_outlined,
        title: parentId == null ? 'No categories yet' : 'No subcategories yet',
        message: parentId == null
            ? 'Add the first category to organize product metadata.'
            : 'Add a subcategory to continue organizing this level.',
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
            onPrevious: currentPage > 1 ? onPreviousPage : null,
            onNext: currentPage < totalPages ? onNextPage : null,
          );
        }
        final item = items[index];
        return KeyedSubtree(
          key: ValueKey<String>(item.id),
          child: CategoryListItem(
            category: item,
            onDelete: () => onDelete(item),
            onDrillDown: () => onDrillDown(item),
            onRefresh: onRefresh,
          ),
        );
      },
    );
  }
}
