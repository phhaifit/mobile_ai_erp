import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_actions_menu.dart';

class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    super.key,
    required this.category,
    required this.onDelete,
  });

  final Category category;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return MetadataListCard(
      title: category.name,
      leading: Icon(
        Icons.folder_outlined,
        size: 28,
      ),
      detailLines: [
        'Slug: ${category.slug}',
        if (category.description?.trim().isNotEmpty == true)
          category.description!.replaceAll(RegExp(r'\s+'), ' ').trim(),
      ],
      trailing: CategoryActionsMenu(
        onSelected: (CategoryMenuAction action) {
          switch (action) {
            case CategoryMenuAction.addChild:
              ProductMetadataNavigator.openCategoryForm(
                context,
                args: CategoryFormArgs(initialParentId: category.id),
              );
              break;
            case CategoryMenuAction.edit:
              ProductMetadataNavigator.openCategoryForm(
                context,
                args: CategoryFormArgs(categoryId: category.id),
              );
              break;
            case CategoryMenuAction.delete:
              onDelete();
              break;
          }
        },
      ),
      onTap: () {
        ProductMetadataNavigator.openCategoryDetail(
          context,
          args: CategoryDetailArgs(categoryId: category.id),
        );
      },
    );
  }
}
