import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_card_small.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class BrandsLandingPage extends StatefulWidget {
  const BrandsLandingPage({super.key});

  @override
  State<BrandsLandingPage> createState() => _BrandsLandingPageState();
}

class _BrandsLandingPageState extends State<BrandsLandingPage> {
  final StorefrontRepository _repository = getIt<StorefrontRepository>();
  late Future<List<StorefrontBrand>> _brandsFuture;

  @override
  void initState() {
    super.initState();
    _brandsFuture = _repository.getBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brands'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.storeHome),
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: FutureBuilder<List<StorefrontBrand>>(
        future: _brandsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final brands = snapshot.data ?? const [];
          return ListView(
            children: [
              const SizedBox(height: 20),
              for (final brand in brands) _buildBrandSection(context, brand),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context, StorefrontBrand brand) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          headingText: brand.name,
          linkText: 'See all products from ${brand.name}',
          linkDestination: Routes.storefrontProductListing,
          filterArguments: FilterArguments(
            selectedBrands: [brand.id],
            brandKey: brand.slug,
          ),
        ),
        if (brand.description != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(brand.description!),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text('${brand.productCount} products available'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: brand.featuredProducts
                .map(
                  (product) => ProductCardSmall(
                    productId: product.id,
                    productName: product.title,
                    imageSource: product.images.isNotEmpty ? product.images.first : null,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
