import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/search_filter_bar.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_listing_item.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/storefront_ui.dart';
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
        _scrollController.position.maxScrollExtent - 240) {
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

  String _headline() {
    if (_listingFilters.searchQuery.isNotEmpty) {
      return 'Results for "${_listingFilters.searchQuery}"';
    }
    if (_listingFilters.activeCollectionSlug != null) {
      return 'Collection discovery';
    }
    if (_listingFilters.activeBrandKey != null) {
      return 'Brand discovery';
    }
    if (_listingFilters.activeCategoryKey != null ||
        _listingFilters.categoryFilter.isNotEmpty) {
      return 'Category discovery';
    }
    return 'All products';
  }

  String _subheadline() {
    if (_listingFilters.hasSearchText) {
      return 'Search results are coming from the live storefront API with keyword highlight support.';
    }
    return 'Browse real storefront results with pagination, sorting and multi-faceted filtering.';
  }

  Widget _buildSummaryCard() {
    return Observer(
      builder: (_) => StorefrontSurface(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                StorefrontTag(
                  label: _listingFilters.totalItems > 0
                      ? '${_listingFilters.totalItems} live results'
                      : 'Live discovery',
                  icon: Icons.travel_explore,
                ),
                StorefrontTag(
                  label: _listingFilters.hasMore
                      ? 'Infinite scroll enabled'
                      : 'End of result set',
                  icon: Icons.swap_vert_circle_outlined,
                  backgroundColor: const Color(0xFFFCE7DF),
                ),
                if (_listingFilters.activeFilterCount > 0)
                  StorefrontTag(
                    label:
                        '${_listingFilters.activeFilterCount} filters applied',
                    icon: Icons.tune,
                    backgroundColor: const Color(0xFFE8F0FF),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _headline(),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              _subheadline(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            if (_listingFilters.breadcrumb.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _listingFilters.breadcrumb
                    .map(
                      (item) => StorefrontTag(
                        label: item.name,
                        icon: Icons.chevron_right_rounded,
                        backgroundColor: const Color(0xFFF6F1E8),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return StorefrontEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No products found',
      message:
          'The current discovery query did not return products. Try broadening search terms, clearing filters or checking if this tenant has published catalog data.',
      actionLabel: 'Retry',
      onPressed: _listingFilters.updateProducts,
    );
  }

  Widget _buildErrorState() {
    return StorefrontEmptyState(
      icon: Icons.cloud_off,
      title: 'Unable to load products',
      message:
          _listingFilters.errorMessage ?? 'Unable to load storefront data.',
      actionLabel: 'Retry',
      onPressed: _listingFilters.updateProducts,
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
        title: const Text('Product Discovery'),
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
        child: Stack(
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

                return RefreshIndicator(
                  onRefresh: _listingFilters.updateProducts,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 150),
                    itemCount:
                        2 +
                        (_listingFilters.products.isEmpty
                            ? 1
                            : _listingFilters.products.length) +
                        (_listingFilters.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildSummaryCard();
                      }
                      if (index == 1) {
                        return SectionHeader(
                          headingText: 'Product results',
                          subheadingText:
                              'Results below are paginated from the backend storefront APIs.',
                        );
                      }

                      if (_listingFilters.products.isEmpty) {
                        return _buildEmptyState();
                      }

                      final productIndex = index - 2;
                      if (productIndex >= _listingFilters.products.length) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
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
      ),
    );
  }
}
