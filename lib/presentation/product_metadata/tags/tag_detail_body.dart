import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag_extensions.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_date_text.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';

class TagDetailBody extends StatelessWidget {
  const TagDetailBody({super.key, required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(tag.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        MetadataDetailSectionCard(
          title: 'Main information',
          children: <Widget>[
            MetadataDetailRow(
              label: 'Description',
              value: tag.descriptionOrNull ?? 'Not set',
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetadataDetailSectionCard(
          title: 'System information',
          children: <Widget>[
            MetadataDetailRow(
              label: 'Created at',
              value: metadataDateText(tag.createdAt),
            ),
            MetadataDetailRow(
              label: 'Updated at',
              value: metadataDateText(tag.updatedAt),
            ),
          ],
        ),
      ],
    );
  }
}
