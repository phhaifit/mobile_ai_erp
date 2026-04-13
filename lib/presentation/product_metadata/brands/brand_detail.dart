import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_extensions.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/brand_logo_avatar.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';

class ProductMetadataBrandDetailScreen extends StatefulWidget {
  const ProductMetadataBrandDetailScreen({super.key, required this.args});

  final BrandDetailArgs args;

  @override
  State<ProductMetadataBrandDetailScreen> createState() =>
      _ProductMetadataBrandDetailScreenState();
}

class _ProductMetadataBrandDetailScreenState
    extends State<ProductMetadataBrandDetailScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  late Future<void> _loadBrandFuture;
  Brand? _brand;

  @override
  void initState() {
    super.initState();
    _loadBrandFuture = _loadBrand();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadBrandFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('Brand detail')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final brand = _brand;
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
                onPressed: () => _editBrand(brand),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit brand',
              ),
            ],
          ),
          body: ListView(
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
                        MetadataStatusChip(
                          label: brand.isActive ? 'Active' : 'Inactive',
                        ),
                      ],
                    ),
                  ),
                  MetadataDetailRow(
                    label: 'Description',
                    value: brand.descriptionOrNull ?? 'Not set',
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

  Future<void> _loadBrand() async {
    try {
      _brand = await _store.getBrandById(widget.args.brandId);
    } catch (_) {
      _brand = null;
    }
  }

  Future<void> _editBrand(Brand brand) async {
    final didChange = await ProductMetadataNavigator.openBrandForm<bool>(
      context,
      args: BrandFormArgs(brandId: brand.id),
    );
    if (didChange == true && mounted) {
      // Reload the brand to get the latest state
      await _loadBrand();
      final updatedBrand = _brand;
      if (!mounted) {
        return;
      }
      // If brand was deactivated, go back to brands list
      if (updatedBrand != null && !updatedBrand.isActive) {
        Navigator.of(context).pop();
        return;
      }
      // Otherwise, refresh the detail view
      setState(() {
        _loadBrandFuture = _loadBrand();
      });
    }
  }
}
