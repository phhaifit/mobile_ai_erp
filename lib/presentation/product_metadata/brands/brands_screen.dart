import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ProductMetadataBrandsScreen extends StatefulWidget {
  const ProductMetadataBrandsScreen({super.key});

  @override
  State<ProductMetadataBrandsScreen> createState() =>
      _ProductMetadataBrandsScreenState();
}

class _ProductMetadataBrandsScreenState
    extends State<ProductMetadataBrandsScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => _store.loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brands'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ProductMetadataNavigator.openBrandForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add brand'),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && !_store.hasLoadedDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_store.brands.isEmpty) {
            return const Center(
              child: Text(
                'No brands yet. Add your first brand to keep product data consistent.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: _store.brands.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final brand = _store.brands[index];
              return MetadataListCard(
                title: brand.name,
                leading: const Icon(Icons.workspace_premium_outlined),
                detailLines: _brandSummary(brand),
                chips: <Widget>[
                  MetadataStatusChip(label: brand.status.label),
                ],
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        ProductMetadataNavigator.openBrandForm(
                          context,
                          args: BrandFormArgs(brandId: brand.id),
                        );
                        break;
                      case 'delete':
                        _deleteBrand(brand);
                        break;
                    }
                  },
                  itemBuilder: (context) => const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
                onTap: () => ProductMetadataNavigator.openBrandDetail(
                  context,
                  args: BrandDetailArgs(brandId: brand.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<String> _brandSummary(Brand brand) {
    return <String>[
      if (brand.description != null && brand.description!.trim().isNotEmpty)
        brand.description!.trim(),
      if (brand.displayLocation != null) 'Location: ${brand.displayLocation}',
      'Sort order: ${brand.sortOrder}',
    ];
  }

  Future<void> _deleteBrand(Brand brand) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete brand?'),
              content: Text('Delete "${brand.name}"? This can\'t be undone.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      await _store.deleteBrand(brand.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${brand.name}".')),
      );
    } catch (error) {
      debugPrint('Failed to delete brand: $error');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t delete brand. Try again.'),
        ),
      );
    }
  }
}
