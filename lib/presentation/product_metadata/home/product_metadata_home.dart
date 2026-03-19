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
                description: 'Keep categories organized in a clear tree.',
                countLabel: '${_store.categories.length} categories',
                icon: Icons.account_tree_outlined,
                onTap: () => ProductMetadataNavigator.openCategories(context),
              ),
              MetadataSectionCard(
                title: 'Attributes',
                description:
                    'Define attribute definitions, options, and rules.',
                countLabel: '${_store.attributes.length} attributes',
                icon: Icons.tune_outlined,
                onTap: () => ProductMetadataNavigator.openAttributes(context),
              ),
              MetadataSectionCard(
                title: 'Brands',
                description: 'Keep one clean brand list for product data.',
                countLabel: '${_store.brands.length} brands',
                icon: Icons.workspace_premium_outlined,
                onTap: () => ProductMetadataNavigator.openBrands(context),
              ),
              MetadataSectionCard(
                title: 'Tags',
                description:
                    'Use tags for campaigns, highlights, and hashtags.',
                countLabel: '${_store.tags.length} tags',
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
