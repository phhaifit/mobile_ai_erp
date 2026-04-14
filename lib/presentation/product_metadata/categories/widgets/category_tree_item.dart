import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_actions_menu.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_info_row.dart';
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
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withAlpha(51)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await ProductMetadataNavigator.openCategoryDetail(
            context,
            args: CategoryDetailArgs(categoryId: category.id),
          );
          await onReload();
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
                    !hasChildren
                        ? Icons.folder_outlined
                        : Icons.account_tree_outlined,
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
                          ).then((_) => onReload());
                          return;
                        case CategoryMenuAction.edit:
                          ProductMetadataNavigator.openCategoryForm(
                            context,
                            args: CategoryFormArgs(categoryId: category.id),
                          ).then((_) => onReload());
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Spacer(),
                        if (hasChildren) ...<Widget>[
                          SubcategoryCountBadge(count: childrenCount),
                          const SizedBox(width: 8),
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
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
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
