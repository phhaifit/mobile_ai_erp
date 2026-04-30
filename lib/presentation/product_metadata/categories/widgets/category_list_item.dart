import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_actions_menu.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_status_chip.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/subcategory_count_badge.dart';

class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    super.key,
    required this.category,
    required this.onDelete,
    this.showDrillDown = true,
    this.onDrillDown,
    this.onRefresh,
  });

  final Category category;
  final VoidCallback onDelete;
  final bool showDrillDown;
  final VoidCallback? onDrillDown;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final childrenCount = category.childrenCount;
    final hasChildren = showDrillDown && childrenCount != null && childrenCount > 0;
    return MetadataListCard(
      title: category.name,
      leading: Icon(
        hasChildren ? Icons.account_tree_outlined : Icons.folder_outlined,
        size: 28,
      ),
      detailLines: [
        if (category.parentId?.isNotEmpty ?? false)
          'Parent: ${category.parentName ?? category.parentId}',
        'Slug: ${category.slug}',
        if (category.description?.trim().isNotEmpty ?? false)
          category.description!.trim(),
      ],
      chips: <Widget>[
        CategoryStatusChip(status: category.status),
        if (!(category.parentId?.isNotEmpty ?? false))
          const MetadataStatusChip(label: 'Top-level category'),
      ],
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasChildren) ...[
            SubcategoryCountBadge(count: childrenCount),
            IconButton(
              onPressed: onDrillDown,
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
                  ).then((_) => onRefresh?.call());
                  break;
                case CategoryMenuAction.edit:
                  ProductMetadataNavigator.openCategoryForm(
                    context,
                    args: CategoryFormArgs(categoryId: category.id),
                  ).then((_) => onRefresh?.call());
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
        onRefresh?.call();
      },
    );
  }
}
