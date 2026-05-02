import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/page_banner.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_card_small.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/storefront_ui.dart';
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

  Future<void> _reload() async {
    setState(() {
      _brandsFuture = _repository.getBrands();
    });
    await _brandsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brands'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.storeHome),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F4EF), Color(0xFFFBFBFA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<StorefrontBrand>>(
          future: _brandsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return StorefrontEmptyState(
                icon: Icons.storefront_outlined,
                title: 'Unable to load brands',
                message: snapshot.error.toString(),
                actionLabel: 'Retry',
                onPressed: _reload,
              );
            }

            final brands = snapshot.data ?? const [];
            if (brands.isEmpty) {
              return StorefrontEmptyState(
                icon: Icons.storefront_outlined,
                title: 'No brands available',
                message:
                    'The public storefront runtime did not return brand landing data for this tenant.',
                actionLabel: 'Refresh',
                onPressed: _reload,
              );
            }

            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 28),
                children: [
                  const PageBanner(
                    imageSource: null,
                    heading: 'Brand Landings',
                    subheading:
                        'Browse brands connected to live discovery APIs and jump into filtered product listings.',
                    tags: ['Live brand data', 'Filtered PLP'],
                  ),
                  for (final brand in brands)
                    _buildBrandSection(context, brand),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context, StorefrontBrand brand) {
    return StorefrontSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            headingText: brand.name,
            subheadingText:
                brand.description ?? 'Explore this brand in the storefront.',
            linkText: 'View all products',
            linkDestination: Routes.storefrontProductListing,
            filterArguments: FilterArguments(
              selectedBrands: [brand.slug],
              brandKey: brand.slug,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                StorefrontTag(
                  label: '${brand.productCount} products',
                  icon: Icons.inventory_2_outlined,
                ),
                StorefrontTag(
                  label: 'Brand slug: ${brand.slug}',
                  icon: Icons.sell_outlined,
                  backgroundColor: const Color(0xFFFCE7DF),
                ),
              ],
            ),
          ),
          if (brand.featuredProducts.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: brand.featuredProducts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = brand.featuredProducts[index];
                  return ProductCardSmall(
                    productId: product.id,
                    productName: product.title,
                    imageSource: product.images.isNotEmpty
                        ? product.images.first
                        : null,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
