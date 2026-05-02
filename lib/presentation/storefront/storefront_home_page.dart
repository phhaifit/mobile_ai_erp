import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/page_banner.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_card_small.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/storefront_ui.dart';
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

    var brands = home.featuredBrands;
    var categories = home.featuredCategories;
    var collections = home.collections;

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

  Future<void> _reload() async {
    setState(() {
      _homeFuture = _loadHomeViewData();
    });
    await _homeFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storefront'),
        actions: [
          IconButton(
            tooltip: 'View all products',
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(Routes.storefrontProductListing),
            icon: const Icon(Icons.grid_view_rounded),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F1E8), Color(0xFFFBFBFA), Color(0xFFFCEDE8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<_StorefrontHomeViewData>(
          future: _homeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return StorefrontEmptyState(
                icon: Icons.cloud_off,
                title: 'Unable to load storefront',
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
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  PageBanner(
                    imageSource: banner,
                    heading: 'Storefront Product Discovery',
                    subheading:
                        'Featured products, collections, categories and search experiences are now connected to the live discovery APIs.',
                    tags: const [
                      'Homepage live data',
                      'Filter-ready listing',
                      'Search highlights',
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildQuickLinks(),
                  if (_isFullyEmpty(viewData))
                    const StorefrontSurface(
                      child: Text(
                        'The app is connected to the public storefront runtime, but discovery endpoints are returning empty data for this tenant right now. The UI is still live and will surface products as soon as backend data is available.',
                      ),
                    ),
                  _buildProductSection(
                    heading: 'Featured Picks',
                    subheading:
                        'Handpicked products surfaced directly from the homepage API.',
                    linkText: 'See all products',
                    products: home.featuredProducts,
                    args: const FilterArguments(),
                    emptyMessage:
                        'No featured products are currently available from the API.',
                  ),
                  _buildProductSection(
                    heading: 'New Arrivals',
                    subheading:
                        'Newest products across the storefront, sorted live from backend.',
                    linkText: 'See newest',
                    products: home.newArrivals,
                    args: const FilterArguments(
                      sortOption: SortOption.timeDesc,
                    ),
                    emptyMessage: 'No new arrivals are available right now.',
                  ),
                  _buildProductSection(
                    heading: 'Popular Right Now',
                    subheading:
                        'Products currently trending in the live storefront feed.',
                    linkText: 'See popular',
                    products: home.popularProducts,
                    args: const FilterArguments(sortOption: SortOption.popular),
                    emptyMessage:
                        'No popular products are available right now.',
                  ),
                  _buildCategorySection(viewData.categories),
                  _buildBrandSection(viewData.brands),
                  _buildCollectionSection(viewData.collections),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickLinks() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          _buildQuickLink(
            icon: Icons.search_rounded,
            label: 'Search',
            onTap: () => Navigator.of(context).pushNamed(
              Routes.storefrontProductListing,
              arguments: const FilterArguments(searchQuery: ''),
            ),
          ),
          const SizedBox(width: 10),
          _buildQuickLink(
            icon: Icons.account_tree_outlined,
            label: 'Categories',
            onTap: () =>
                Navigator.of(context).pushNamed(Routes.categoriesLanding),
          ),
          const SizedBox(width: 10),
          _buildQuickLink(
            icon: Icons.local_offer_outlined,
            label: 'Brands',
            onTap: () => Navigator.of(context).pushNamed(Routes.brandsLanding),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.24),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSection({
    required String heading,
    required String subheading,
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
          subheadingText: subheading,
          linkText: linkText,
          linkDestination: Routes.storefrontProductListing,
          filterArguments: args,
        ),
        if (products.isEmpty)
          StorefrontSurface(
            child: Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
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
    );
  }

  Widget _buildCategorySection(List<StorefrontCategorySummary> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          headingText: 'Shop by Category',
          subheadingText:
              'Browse the category tree loaded directly from the discovery API.',
          linkText: 'See all categories',
          linkDestination: Routes.categoriesLanding,
        ),
        if (categories.isEmpty)
          StorefrontSurface(
            child: Text(
              'Category navigation is currently empty on the public runtime.',
            ),
          )
        else
          StorefrontSurface(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories
                  .map(
                    (category) => ActionChip(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      avatar: const Icon(Icons.arrow_outward_rounded, size: 16),
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
      ],
    );
  }

  Widget _buildBrandSection(List<StorefrontBrand> brands) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          headingText: 'Featured Brands',
          subheadingText:
              'Brand landing data is loaded live and can jump directly into filtered product listings.',
          linkText: 'See all brands',
          linkDestination: Routes.brandsLanding,
        ),
        if (brands.isEmpty)
          StorefrontSurface(
            child: Text('No brand discovery data is currently available.'),
          )
        else
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: brands.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final brand = brands[index];
                return _DiscoveryEntityCard(
                  width: 260,
                  title: brand.name,
                  subtitle:
                      brand.description ?? 'Explore products from this brand.',
                  caption: '${brand.productCount} products',
                  onTap: () => Navigator.of(context).pushNamed(
                    Routes.storefrontProductListing,
                    arguments: FilterArguments(
                      selectedBrands: [brand.id],
                      brandKey: brand.slug,
                    ),
                  ),
                );
              },
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
          subheadingText:
              'Collections surface curated sets of products from the live catalog.',
          linkText: 'Browse collections',
          linkDestination: Routes.collectionsLanding,
        ),
        if (collections.isEmpty)
          StorefrontSurface(
            child: Text('No collection discovery data is currently available.'),
          )
        else
          SizedBox(
            height: 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: collections.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final collection = collections[index];
                return _DiscoveryEntityCard(
                  width: 280,
                  title: collection.name,
                  subtitle:
                      collection.description ??
                      'Open the live collection landing and browse products.',
                  caption: '${collection.productCount} items',
                  onTap: () => Navigator.of(context).pushNamed(
                    Routes.storefrontProductListing,
                    arguments: FilterArguments(collectionSlug: collection.slug),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _DiscoveryEntityCard extends StatelessWidget {
  const _DiscoveryEntityCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.caption,
    required this.onTap,
  });

  final double width;
  final String title;
  final String subtitle;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF8ECE7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StorefrontTag(
                label: 'Discovery landing',
                icon: Icons.auto_graph,
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                caption,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: colorScheme.primary),
              ),
            ],
          ),
        ),
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
