import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';

class CategoriesTreeEmptyState extends StatelessWidget {
  const CategoriesTreeEmptyState({super.key, required this.parent});

  final Category? parent;

  @override
  Widget build(BuildContext context) {
    final isRoot = parent == null;
    return MetadataEmptyState(
      icon: isRoot ? Icons.account_tree_outlined : Icons.folder_open_outlined,
      title: isRoot ? 'No categories yet' : 'No subcategories yet',
      message: isRoot
          ? 'Add the first category to organize product metadata.'
          : 'Add a subcategory to continue organizing this level.',
    );
  }
}
