import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/search_filter_bar.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_listing_item.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final _listingFilters = getIt<ListingFilters>();
  final ScrollController _scrollController = ScrollController();
  bool _appliedArgs = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _listingFilters.loadMore();
    }
  }

  Future<void> _applyRouteArguments(FilterArguments? args) {
    return _listingFilters.applyArguments(
      search: args?.searchQuery,
      categories: args?.selectedCategories,
      brands: args?.selectedBrands,
      attributeValueIds: args?.selectedAttributeValueIds,
      sort: args?.sortOption,
      categoryKey: args?.categoryKey,
      brandKey: args?.brandKey,
      collectionSlug: args?.collectionSlug,
      minPrice: args?.minPrice,
      maxPrice: args?.maxPrice,
      rating: args?.rating,
      availability: args?.availability,
    );
  }

  Widget _buildHeadline(BuildContext context) {
    final theme = Theme.of(context);
    final title = _listingFilters.searchQuery.isNotEmpty
        ? 'Results for "${_listingFilters.searchQuery}"'
        : _listingFilters.activeCollectionSlug != null
        ? 'Collection'
        : _listingFilters.activeBrandKey != null
        ? 'Brand products'
        : 'Products';
    return Text(title, style: theme.textTheme.headlineMedium);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              'No products are available for the current discovery query.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'The mobile app is connected to the public storefront runtime. This environment may currently return empty discovery data even when the backend contract is reachable.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _listingFilters.updateProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(
              _listingFilters.errorMessage ?? 'Unable to load storefront data.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _listingFilters.updateProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as FilterArguments?;
    if (!_appliedArgs) {
      _appliedArgs = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyRouteArguments(args);
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Observer(builder: (_) => _buildHeadline(context)),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.storeHome),
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Stack(
        children: [
          Observer(
            builder: (_) {
              if (_listingFilters.isLoading &&
                  _listingFilters.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_listingFilters.errorMessage != null &&
                  _listingFilters.products.isEmpty) {
                return _buildErrorState();
              }
              if (_listingFilters.products.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: _listingFilters.updateProducts,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(
                    bottom: kBottomNavigationBarHeight + 32,
                    top: 8,
                  ),
                  itemCount:
                      (_listingFilters.breadcrumb.isNotEmpty ? 1 : 0) +
                      _listingFilters.products.length +
                      (_listingFilters.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_listingFilters.breadcrumb.isNotEmpty && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          _listingFilters.breadcrumb
                              .map((item) => item.name)
                              .join(' / '),
                        ),
                      );
                    }

                    final productIndex =
                        index - (_listingFilters.breadcrumb.isNotEmpty ? 1 : 0);
                    if (productIndex >= _listingFilters.products.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return ProductListingItem(
                      productListing: _listingFilters.products[productIndex],
                      highlightText: _listingFilters.searchQuery,
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Observer(
              builder: (_) => SearchFilterBar(
                brands: _listingFilters.brands.toList(),
                categories: _listingFilters.categories.toList(),
                attributes: _listingFilters.attributeFacets.toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
