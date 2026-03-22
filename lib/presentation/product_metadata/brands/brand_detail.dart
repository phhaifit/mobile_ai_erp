import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ProductMetadataBrandDetailScreen extends StatefulWidget {
  const ProductMetadataBrandDetailScreen({
    super.key,
    required this.args,
  });

  final BrandDetailArgs args;

  @override
  State<ProductMetadataBrandDetailScreen> createState() =>
      _ProductMetadataBrandDetailScreenState();
}

class _ProductMetadataBrandDetailScreenState
    extends State<ProductMetadataBrandDetailScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => _store.loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final brand = _store.findBrandById(widget.args.brandId);
        if (brand == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Brand detail')),
            body: const Center(child: Text('Brand not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Brand detail'),
            actions: <Widget>[
              IconButton(
                onPressed: () => ProductMetadataNavigator.openBrandForm(
                  context,
                  args: BrandFormArgs(brandId: brand.id),
                ),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit brand',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                brand.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
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
                        MetadataStatusChip(label: brand.status.label),
                      ],
                    ),
                  ),
                  MetadataDetailRow(
                    label: 'Code',
                    value: brand.code,
                  ),
                  if (brand.description != null &&
                      brand.description!.isNotEmpty)
                    MetadataDetailRow(
                      label: 'Description',
                      value: brand.description!,
                    ),
                  if (brand.displayLocation != null)
                    MetadataDetailRow(
                      label: 'Location',
                      value: brand.displayLocation!,
                    ),
                  MetadataDetailRow(
                    label: 'Sort order',
                    value: brand.sortOrder.toString(),
                  ),
                ],
              ),
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
            ],
          ),
        );
      },
    );
  }
}
