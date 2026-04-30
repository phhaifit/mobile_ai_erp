import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/page_banner.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_card_small.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class StorefrontHomePage extends StatefulWidget {
  const StorefrontHomePage({super.key});

  @override
  State<StorefrontHomePage> createState() => _StorefrontHomePageState();
}

class _StorefrontHomePageState extends State<StorefrontHomePage> {
  final StorefrontRepository _repository = getIt<StorefrontRepository>();
  late Future<_StorefrontHomeViewData> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeViewData();
  }

  Future<_StorefrontHomeViewData> _loadHomeViewData() async {
    final home = await _repository.getHome();

    List<StorefrontBrand> brands = home.featuredBrands;
    List<StorefrontCategorySummary> categories = home.featuredCategories;
    List<StorefrontCollection> collections = home.collections;

    if (brands.isEmpty) {
      brands = await _repository.getBrands();
    }
    if (categories.isEmpty) {
      final categoryTree = await _repository.getCategories();
      categories = categoryTree
          .map(
            (item) => StorefrontCategorySummary(
              id: item.id,
              name: item.name,
              slug: item.slug,
            ),
          )
          .toList();
    }
    if (collections.isEmpty) {
      collections = await _repository.getCollections();
    }

    return _StorefrontHomeViewData(
      home: home,
      brands: brands,
      categories: categories,
      collections: collections,
    );
  }

  bool _isFullyEmpty(_StorefrontHomeViewData data) {
    return data.home.featuredProducts.isEmpty &&
        data.home.newArrivals.isEmpty &&
        data.home.popularProducts.isEmpty &&
        data.brands.isEmpty &&
        data.categories.isEmpty &&
        data.collections.isEmpty;
  }

  Widget _buildSectionMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storefront Homepage')),
      body: FutureBuilder<_StorefrontHomeViewData>(
        future: _homeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _AsyncState(
              icon: Icons.cloud_off,
              message: snapshot.error.toString(),
              actionLabel: 'Retry',
              onPressed: () {
                setState(() {
                  _homeFuture = _loadHomeViewData();
                });
              },
            );
          }

          final viewData = snapshot.data!;
          final home = viewData.home;
          final banner = home.banners.isNotEmpty ? home.banners.first : null;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _homeFuture = _loadHomeViewData();
              });
              await _homeFuture;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageBanner(
                    imageSource: banner,
                    heading: 'Storefront Product Discovery',
                  ),
                  const SizedBox(height: 20),
                  if (_isFullyEmpty(viewData))
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'The mobile app is connected to the public storefront runtime, but discovery endpoints are currently returning empty data for this tenant. The UI remains live and will surface data as soon as the backend runtime is healthy.',
                          ),
                        ),
                      ),
                    ),
                  _buildProductSection(
                    heading: 'Featured',
                    linkText: 'See all products',
                    products: home.featuredProducts,
                    args: const FilterArguments(),
                    emptyMessage:
                        'No featured products are currently available from the API.',
                  ),
                  _buildProductSection(
                    heading: 'New Arrivals',
                    linkText: 'See newest products',
                    products: home.newArrivals,
                    args: const FilterArguments(
                      sortOption: SortOption.timeDesc,
                    ),
                    emptyMessage: 'No new arrivals are available right now.',
                  ),
                  _buildProductSection(
                    heading: 'Popular',
                    linkText: 'See popular products',
                    products: home.popularProducts,
                    args: const FilterArguments(sortOption: SortOption.popular),
                    emptyMessage:
                        'No popular products are available right now.',
                  ),
                  _buildCategorySection(viewData.categories),
                  _buildBrandSection(viewData.brands),
                  _buildCollectionSection(viewData.collections),
                  const SizedBox(height: 24),
                ],
              ),
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
    required String emptyMessage,
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
        if (products.isEmpty)
          _buildSectionMessage(emptyMessage)
        else
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
        if (categories.isEmpty)
          _buildSectionMessage(
            'Category navigation is currently empty on the public runtime.',
          )
        else
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
        if (brands.isEmpty)
          _buildSectionMessage(
            'No brand discovery data is currently available.',
          )
        else
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
                if (brand.featuredProducts.isEmpty)
                  _buildSectionMessage(
                    'No featured products returned for this brand.',
                  )
                else
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
          linkDestination: Routes.collectionsLanding,
        ),
        if (collections.isEmpty)
          _buildSectionMessage(
            'No collection discovery data is currently available.',
          )
        else
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
                if (collection.featuredProducts.isEmpty)
                  _buildSectionMessage(
                    'No featured products returned for this collection.',
                  )
                else
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
                imageSource: product.images.isNotEmpty
                    ? product.images.first
                    : null,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _StorefrontHomeViewData {
  const _StorefrontHomeViewData({
    required this.home,
    required this.brands,
    required this.categories,
    required this.collections,
  });

  final StorefrontHomeData home;
  final List<StorefrontBrand> brands;
  final List<StorefrontCategorySummary> categories;
  final List<StorefrontCollection> collections;
}

class _AsyncState extends StatelessWidget {
  const _AsyncState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
