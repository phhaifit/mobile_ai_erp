import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_actions_menu.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_status_chip.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/subcategory_count_badge.dart';

class CategoryTreeItem extends StatelessWidget {
  const CategoryTreeItem({
    super.key,
    required this.category,
    required this.hasChildren,
    required this.childrenCount,
    required this.onDelete,
    required this.onReload,
  });

  final Category category;
  final bool hasChildren;
  final int childrenCount;
  final VoidCallback onDelete;
  final Future<void> Function() onReload;

  @override
  Widget build(BuildContext context) {
    return MetadataListCard(
      title: category.name,
      leading: Icon(
        !hasChildren ? Icons.folder_outlined : Icons.account_tree_outlined,
        size: 28,
      ),
      detailLines: [
        'Slug: ${category.slug}',
        if (category.description?.trim().isNotEmpty == true)
          category.description!.replaceAll(RegExp(r'\s+'), ' ').trim(),
      ],
      chips: <Widget>[CategoryStatusChip(status: category.status)],
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasChildren) ...[
            SubcategoryCountBadge(count: childrenCount),
            IconButton(
              onPressed: () {
                ProductMetadataNavigator.openCategories(
                  context,
                  args: CategoriesArgs(
                    parentCategoryId: category.id,
                    initialTabIndex: 1,
                  ),
                );
              },
              icon: const Icon(Icons.chevron_right),
              tooltip: 'View subcategories',
              visualDensity: VisualDensity.compact,
              iconSize: 20,
            ),
          ],
          CategoryActionsMenu(
            onSelected: (CategoryMenuAction action) {
              switch (action) {
                case CategoryMenuAction.addChild:
                  ProductMetadataNavigator.openCategoryForm(
                    context,
                    args: CategoryFormArgs(initialParentId: category.id),
                  ).then((_) => onReload());
                  break;
                case CategoryMenuAction.edit:
                  ProductMetadataNavigator.openCategoryForm(
                    context,
                    args: CategoryFormArgs(categoryId: category.id),
                  ).then((_) => onReload());
                  break;
                case CategoryMenuAction.delete:
                  onDelete();
                  break;
              }
            },
          ),
        ],
      ),
      onTap: () async {
        await ProductMetadataNavigator.openCategoryDetail(
          context,
          args: CategoryDetailArgs(categoryId: category.id),
        );
        await onReload();
      },
    );
  }
}
