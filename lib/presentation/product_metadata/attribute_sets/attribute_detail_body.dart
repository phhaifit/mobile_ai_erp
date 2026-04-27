import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/date_formatter.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';

class AttributeDetailBody extends StatelessWidget {
  const AttributeDetailBody({
    super.key,
    required this.item,
    required this.onManageValues,
  });

  final AttributeSet item;
  final VoidCallback onManageValues;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        MetadataDetailSectionCard(
          title: 'Main information',
          children: <Widget>[
            MetadataDetailRow(
              label: 'Description',
              value: item.description?.trim().isNotEmpty == true
                  ? item.description!
                  : 'Not set',
            ),
            MetadataDetailRow(
              label: 'Values',
              valueChild: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.values.length.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextButton(
                    onPressed: onManageValues,
                    child: const Text('Manage'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetadataDetailSectionCard(
          title: 'System information',
          children: <Widget>[
            MetadataDetailRow(
              label: 'Created at',
              value: DateFormatter.formatFull(item.createdAt),
            ),
            MetadataDetailRow(
              label: 'Updated at',
              value: DateFormatter.formatFull(item.updatedAt),
            ),
          ],
        ),
      ],
    );
  }
}
