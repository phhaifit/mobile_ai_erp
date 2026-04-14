import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/date_formatter.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';

class UnitDetailContent extends StatelessWidget {
  const UnitDetailContent({super.key, required this.unit});

  final Unit unit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(unit.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        MetadataDetailSectionCard(
          title: 'Main information',
          children: <Widget>[
            MetadataDetailRow(
              label: 'Status',
              valueChild: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  MetadataStatusChip(
                    label: unit.isActive ? 'Active' : 'Inactive',
                  ),
                ],
              ),
            ),
            MetadataDetailRow(
              label: 'Symbol',
              value: unit.symbol?.trim().isNotEmpty == true
                  ? unit.symbol!
                  : 'Not set',
            ),
            MetadataDetailRow(
              label: 'Description',
              value: unit.description?.trim().isNotEmpty == true
                  ? unit.description!
                  : 'Not set',
            ),
            MetadataDetailRow(
              label: 'Created at',
              value: DateFormatter.formatFull(unit.createdAt),
            ),
          ],
        ),
      ],
    );
  }
}
