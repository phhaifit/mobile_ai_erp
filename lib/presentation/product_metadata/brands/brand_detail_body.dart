import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/date_formatter.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_extensions.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/brand_logo_avatar.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';

class BrandDetailBody extends StatelessWidget {
  const BrandDetailBody({super.key, required this.brand});

  final Brand brand;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Center(
          child: BrandLogoAvatar(
            name: brand.name,
            logoUrl: brand.logoUrl,
            radius: 32,
          ),
        ),
        const SizedBox(height: 12),
        Text(brand.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        MetadataDetailSectionCard(
          title: 'Main information',
          children: <Widget>[
            MetadataDetailRow(
              label: 'Description',
              value: brand.descriptionOrNull ?? 'Not set',
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetadataDetailSectionCard(
          title: 'Asset',
          children: <Widget>[
            MetadataDetailRow(
              label: 'Logo URL',
              value: brand.logoUrl?.trim().isNotEmpty == true
                  ? brand.logoUrl!
                  : 'Not set',
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetadataDetailSectionCard(
          title: 'System information',
          children: <Widget>[
            MetadataDetailRow(
              label: 'Created at',
              value: DateFormatter.formatFull(brand.createdAt),
            ),
            MetadataDetailRow(
              label: 'Updated at',
              value: DateFormatter.formatFull(brand.updatedAt),
            ),
          ],
        ),
      ],
    );
  }
}
