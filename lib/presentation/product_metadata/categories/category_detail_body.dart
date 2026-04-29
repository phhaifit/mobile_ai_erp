import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_status_chip.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_date_text.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';

class CategoryDetailBody extends StatelessWidget {
  const CategoryDetailBody({
    super.key,
    required this.category,
    required this.parent,
    required this.onViewChildren,
  });

  final Category category;
  final Category? parent;
  final VoidCallback? onViewChildren;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(category.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        MetadataDetailSectionCard(
          title: 'Main information',
          children: <Widget>[
            MetadataDetailRow(label: 'Status', valueChild: CategoryStatusChip(status: category.status)),
            MetadataDetailRow(label: 'Name', value: category.name),
            MetadataDetailRow(label: 'Slug', value: category.slug),
            MetadataDetailRow(label: 'Description', value: _optional(category.description)),
          ],
        ),
        const SizedBox(height: 12),
        MetadataDetailSectionCard(
          title: 'Hierarchy',
          children: <Widget>[
            MetadataDetailRow(label: 'Parent', value: parent?.name ?? 'Top-level category'),
            MetadataDetailRow(label: 'Level', value: category.level.toString()),
            if (category.childrenCount != null)
              MetadataDetailRow(
                label: 'Children',
                valueChild: _ChildrenCountAction(
                  count: category.childrenCount!,
                  onPressed: onViewChildren,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        MetadataDetailSectionCard(
          title: 'System information',
          children: <Widget>[
            MetadataDetailRow(label: 'Created at', value: metadataDateText(category.createdAt)),
            MetadataDetailRow(label: 'Updated at', value: metadataDateText(category.updatedAt)),
          ],
        ),
      ],
    );
  }

  String _optional(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? 'Not set' : trimmed;
  }
}

class _ChildrenCountAction extends StatelessWidget {
  const _ChildrenCountAction({required this.count, required this.onPressed});

  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final text = '$count ${count == 1 ? 'child' : 'children'}';
    if (count == 0 || onPressed == null) return Text(text);
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.account_tree_outlined),
      label: Text(text),
    );
  }
}
