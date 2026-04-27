import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ProductMetadataHomeScreen extends StatefulWidget {
  const ProductMetadataHomeScreen({super.key});

  @override
  State<ProductMetadataHomeScreen> createState() =>
      _ProductMetadataHomeScreenState();
}

class _ProductMetadataHomeScreenState extends State<ProductMetadataHomeScreen> {
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
        title: const Text('Product Metadata'),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && !_store.hasLoadedDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              MetadataSectionCard(
                title: 'Categories',
                description: 'Manage how items are organized in the catalog.',
                countLabel: '${_store.categoryUnfilteredTotal} categories',
                icon: Icons.account_tree_outlined,
                onTap: () => ProductMetadataNavigator.openCategories(context),
              ),
              MetadataSectionCard(
                title: 'Attribute Sets',
                description: 'Define attributes and values for item data.',
                countLabel: '${_store.attributeSetUnfilteredTotal} attribute sets',
                icon: Icons.tune_outlined,
                onTap: () => ProductMetadataNavigator.openAttributes(context),
              ),
              MetadataSectionCard(
                title: 'Brands',
                description: 'Manage the brands available in your catalog.',
                countLabel: '${_store.brandUnfilteredTotal} brands',
                icon: Icons.workspace_premium_outlined,
                onTap: () => ProductMetadataNavigator.openBrands(context),
              ),
              MetadataSectionCard(
                title: 'Tags',
                description:
                    'Use tags to group items for campaigns and highlights.',
                countLabel: '${_store.tagUnfilteredTotal} tags',
                icon: Icons.sell_outlined,
                onTap: () => ProductMetadataNavigator.openTags(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
