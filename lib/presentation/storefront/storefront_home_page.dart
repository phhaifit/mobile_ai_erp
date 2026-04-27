import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/page_banner.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_card_small.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class StorefrontHomePage extends StatefulWidget {
  const StorefrontHomePage({super.key});

  @override
  State<StorefrontHomePage> createState() => _StorefrontHomePageState();
}

class _StorefrontHomePageState extends State<StorefrontHomePage> {
  final StorefrontRepository _repository = getIt<StorefrontRepository>();
  late Future<StorefrontHomeData> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _repository.getHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storefront Homepage')),
      body: FutureBuilder<StorefrontHomeData>(
        future: _homeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _homeFuture = _repository.getHome();
                });
              },
            );
          }

          final home = snapshot.data!;
          final banner = home.banners.isNotEmpty ? home.banners.first : null;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageBanner(imageSource: banner, heading: 'Welcome'),
                const SizedBox(height: 20),
                _buildProductSection(
                  heading: 'Featured',
                  linkText: 'See all products',
                  products: home.featuredProducts,
                  args: const FilterArguments(),
                ),
                _buildProductSection(
                  heading: 'New Arrivals',
                  linkText: 'See newest products',
                  products: home.newArrivals,
                  args: const FilterArguments(sortOption: SortOption.timeDesc),
                ),
                _buildProductSection(
                  heading: 'Popular',
                  linkText: 'See popular products',
                  products: home.popularProducts,
                  args: const FilterArguments(sortOption: SortOption.popular),
                ),
                _buildCategorySection(home.featuredCategories),
                _buildBrandSection(home.featuredBrands),
                _buildCollectionSection(home.collections),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSection({
    required String heading,
    required String linkText,
    required List<StorefrontProduct> products,
    required FilterArguments args,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          headingText: heading,
          linkText: linkText,
          linkDestination: Routes.storefrontProductListing,
          filterArguments: args,
        ),
        _buildProductWrap(products),
      ],
    );
  }

  Widget _buildCategorySection(List<StorefrontCategorySummary> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          headingText: 'Categories',
          linkText: 'See all categories',
          linkDestination: Routes.categoriesLanding,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map(
                  (category) => ActionChip(
                    label: Text(category.name),
                    onPressed: () => Navigator.of(context).pushNamed(
                      Routes.storefrontProductListing,
                      arguments: FilterArguments(
                        selectedCategories: [category.id],
                        categoryKey: category.slug,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBrandSection(List<StorefrontBrand> brands) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          headingText: 'Brands',
          linkText: 'See all brands',
          linkDestination: Routes.brandsLanding,
        ),
        ...brands.map(
          (brand) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(brand.name),
                  subtitle: brand.description != null
                      ? Text(brand.description!)
                      : null,
                  trailing: Text('${brand.productCount} products'),
                  onTap: () => Navigator.of(context).pushNamed(
                    Routes.storefrontProductListing,
                    arguments: FilterArguments(
                      selectedBrands: [brand.id],
                      brandKey: brand.slug,
                    ),
                  ),
                ),
              ),
              _buildProductWrap(brand.featuredProducts),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionSection(List<StorefrontCollection> collections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          headingText: 'Collections',
          linkText: 'Browse collections',
          linkDestination: Routes.storefrontProductListing,
        ),
        ...collections.map(
          (collection) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(collection.name),
                  subtitle: collection.description != null
                      ? Text(collection.description!)
                      : null,
                  trailing: Text('${collection.productCount} items'),
                  onTap: () => Navigator.of(context).pushNamed(
                    Routes.storefrontProductListing,
                    arguments: FilterArguments(
                      collectionSlug: collection.slug,
                    ),
                  ),
                ),
              ),
              _buildProductWrap(collection.featuredProducts),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProductWrap(List<StorefrontProduct> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: products
            .map(
              (product) => ProductCardSmall(
                productId: product.id,
                productName: product.title,
                imageSource: product.images.isNotEmpty ? product.images.first : null,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
