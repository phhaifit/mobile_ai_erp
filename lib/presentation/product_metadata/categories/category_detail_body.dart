import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/date_formatter.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_status_chip.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';

class CategoryDetailBody extends StatelessWidget {
  const CategoryDetailBody({
    super.key,
    required this.category,
    required this.parent,
  });

  final Category category;
  final Category? parent;

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
          ],
        ),
        const SizedBox(height: 12),
        MetadataDetailSectionCard(
          title: 'System information',
          children: <Widget>[
            MetadataDetailRow(label: 'Created at', value: DateFormatter.formatFull(category.createdAt)),
            MetadataDetailRow(label: 'Updated at', value: DateFormatter.formatFull(category.updatedAt)),
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
