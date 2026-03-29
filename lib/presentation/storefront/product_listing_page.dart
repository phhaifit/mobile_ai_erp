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

  @override
  void initState() {
    super.initState();
    _listingFilters.updateProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final args = ModalRoute.of(context)?.settings.arguments as FilterArguments?;
    if (args != null) {
      if (args.searchQuery != null) {
        _listingFilters.setSearchQuery(args.searchQuery!);
      }
      if (args.selectedBrands != null) {
        _listingFilters.clearBrandFilters();
        _listingFilters.setBrandFilter(args.selectedBrands!);
      }
      if (args.selectedCategories != null) {
        _listingFilters.clearCategoryFilters();
        _listingFilters.setCategoryFilter(args.selectedCategories!);
      }
      if (args.sortOption != null) {
        _listingFilters.setSortOption(args.sortOption!);
      }
      _listingFilters.updateProducts();
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
          Observer(builder: (_) => Container(
              color: Colors.teal[100],
              child: ListView.builder(
                itemCount: _listingFilters.products.length,
                itemBuilder: (context, index) {
                  return Observer(builder: (_) => ProductListingItem(productListing: _listingFilters.products[index], highlightText: _listingFilters.searchQuery));
                },
              ),
            )
          ),
          Positioned( 
            left: 0,
            right: 0,
            bottom: 0,
            child: SearchFilterBar(brands: _listingFilters.testBrands, categories: _listingFilters.testCategories)
          )
        ],
      ),
      // bottomNavigationBar: 
    );
  }
}