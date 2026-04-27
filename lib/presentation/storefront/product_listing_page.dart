import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_listing_item.dart';
import 'package:mobile_ai_erp/presentation/storefront/search_filter_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final args = ModalRoute.of(context)?.settings.arguments as FilterArguments?;
    if (!_appliedArgs) {
      _appliedArgs = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _listingFilters.applyArguments(
          search: args?.searchQuery,
          categories: args?.selectedCategories,
          brands: args?.selectedBrands,
          sort: args?.sortOption,
          categoryKey: args?.categoryKey,
          brandKey: args?.brandKey,
          collectionSlug: args?.collectionSlug,
        );
      });
    }
        
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Products',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(onPressed: () => Navigator.of(context).pushNamed(Routes.storeHome), icon: Icon(Icons.home))
        ],
      ),
      body: Stack(
        children: [
          Observer(
            builder: (_) {
              if (_listingFilters.isLoading && _listingFilters.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_listingFilters.errorMessage != null &&
                  _listingFilters.products.isEmpty) {
                return Center(child: Text(_listingFilters.errorMessage!));
              }
              return Container(
                color: Colors.teal[100],
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    bottom: kBottomNavigationBarHeight + 24,
                    top: 8,
                  ),
                  itemCount: (_listingFilters.breadcrumb.isNotEmpty ? 1 : 0) +
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
                          style: theme.textTheme.bodyMedium,
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
          )
        ],
      ),
      // bottomNavigationBar: 
    );
  }
}
