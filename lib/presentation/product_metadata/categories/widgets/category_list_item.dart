import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_actions_menu.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_info_row.dart';

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
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(51)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ProductMetadataNavigator.openCategoryDetail(
            context,
            args: CategoryDetailArgs(categoryId: category.id),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.folder_outlined,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                  ),
                  CategoryActionsMenu(
                    onSelected: (CategoryMenuAction action) {
                      switch (action) {
                        case CategoryMenuAction.addChild:
                          ProductMetadataNavigator.openCategoryForm(
                            context,
                            args: CategoryFormArgs(
                              initialParentId: category.id,
                            ),
                          );
                          return;
                        case CategoryMenuAction.edit:
                          ProductMetadataNavigator.openCategoryForm(
                            context,
                            args: CategoryFormArgs(categoryId: category.id),
                          );
                          return;
                        case CategoryMenuAction.delete:
                          onDelete();
                          return;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CategoryInfoRow(
                      label: 'Slug',
                      value: category.slug,
                      showDivider:
                          category.description?.trim().isNotEmpty == true,
                    ),
                    if (category.description?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      CategoryInfoRow(
                        label: 'Description',
                        value: category.description!,
                        showDivider: false,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
