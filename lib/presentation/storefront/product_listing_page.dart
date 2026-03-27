import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/storefront/product_listing/product_listing_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/product_listing_item.dart';
import 'package:mobile_ai_erp/presentation/storefront/search_filter_bar.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
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
      ),
      body: Stack(
        children: [
          Observer(builder: (_) => Container(
              color: Colors.teal[100],
              child: ListView.builder(
                itemCount: _listingFilters.products.length,
                itemBuilder: (context, index) {
                  return Observer(builder: (_) => ProductListingItem(productListing: _listingFilters.products[index]));
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