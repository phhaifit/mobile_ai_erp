import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/categories_tree_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/categories_level_header.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_tree_item.dart';

class CategoriesTreeTab extends StatelessWidget {
  const CategoriesTreeTab({
    super.key,
    required this.store,
    required this.parentId,
    required this.hasActiveFilter,
    required this.onDelete,
    required this.onOpenFilter,
    required this.onReload,
  });

  final ProductMetadataStore store;
  final String? parentId;
  final bool hasActiveFilter;
  final void Function(Category category) onDelete;
  final VoidCallback onOpenFilter;
  final Future<void> Function() onReload;

  @override
  Widget build(BuildContext context) {
    final categories = store.categoryTree.where((cat) => cat.parentId == parentId).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: CategoriesLevelHeader(
            path: _buildPath(),
            hasActiveFilter: hasActiveFilter,
            onNavigateToLevel: (nextParentId) {
              if (nextParentId == parentId) return;
              ProductMetadataNavigator.openCategories(
                context,
                args: CategoriesArgs(parentCategoryId: nextParentId, initialTabIndex: 1),
              );
            },
            onOpenFilter: onOpenFilter,
          ),
        ),
        Expanded(
          child: categories.isEmpty
              ? CategoriesTreeEmptyState(parent: _findCategory(parentId))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final children = store.categoryTree.where((cat) => cat.parentId == category.id).toList();
                    return KeyedSubtree(
                      key: ValueKey<String>(category.id),
                      child: CategoryTreeItem(
                        category: category,
                        hasChildren: children.isNotEmpty,
                        childrenCount: children.length,
                        onDelete: () => onDelete(category),
                        onReload: onReload,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  List<Category> _buildPath() {
    final path = <Category>[];
    var current = _findCategory(parentId);
    while (current != null) {
      path.insert(0, current);
      current = _findCategory(current.parentId);
    }
    return path;
  }

  Category? _findCategory(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final cat in store.categoryTree) {
      if (cat.id == id) return cat;
    }
    return null;
  }
}
