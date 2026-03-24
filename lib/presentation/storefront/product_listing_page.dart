import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/storefront/product_listing_item.dart';

enum SortOption {
  timeAsc, // oldest first
  timeDesc, // newest first
  nameAsc, // a-z
  nameDesc, // z-a
  priceAsc,
  priceDesc,
  rating, // highest rating first
}

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {

  // states, currently for this page only 
  String searchQuery = ''; // search text
  List<String> categoryFilter = []; // category ids from filters
  List<String> brandFilter = []; // brand ids from filters
  SortOption? sortOption = SortOption.timeDesc; // sorting option, e.g. price_asc, price_desc, rating, etc.

  bool searchOpen = false; // expands search bar
  bool filterOpen = false; // expands filter options
  bool sortOpen = false; // expands sort options

  List<Product> products = []; // products to display, fetched from API based on search and filters

  List<Product> testData = [
    Product(
      id: 'PT1',
      productName: 'Product A',
      category: Category(id: 'CAT1', name: 'Category 1', code: 'CAT1', slug: 'category-1'),
      brand: Brand(id: 'BRAND1', name: 'Brand A', code: 'BRAND1', ),
      rating: 4.5,
      price: 19.99,
      currency: 'USD',
      imageSource: 'https://picsum.photos/250?image=2',
    ),
    Product(
      id: 'PT2',
      productName: 'Product B',
      category: Category(id: 'CAT2', name: 'Category 2', code: 'CAT2', slug: 'category-2'),
      brand: Brand(id: 'BRAND2', name: 'Brand B', code: 'BRAND2'),
      rating: 4.0,
      price: 29.99,
      currency: 'USD',
      imageSource: null, // No image source provided
    ),
  ];

  List<Product> fetchProducts(String searchQuery, List<String> categoryFilter, List<String> brandFilter) { // fetch products over API (from DB)
    return filteredProductsTest(searchQuery, categoryFilter, brandFilter); // for testing, use filtered test data instead of API call
  }
  List<Product> sortProducts(List<Product> products, SortOption? sortOption) {
    List<Product> sortedProducts = List.from(products);
    switch (sortOption) {
      case SortOption.timeAsc:
        // sort by time ascending, if product has a createdAt field
        break;
      case SortOption.timeDesc:
        // sort by time descending, if product has a createdAt field
        break;
      case SortOption.nameAsc:
        sortedProducts.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case SortOption.nameDesc:
        sortedProducts.sort((a, b) => b.productName.compareTo(a.productName));
        break;
      case SortOption.priceAsc:
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        break;
    }
    return sortedProducts;
  }

  List<Product> filteredProductsTest(String searchQuery, List<String> categoryFilter, List<String> brandFilter) { // mock function with test data
    return testData.where((product) {
      final matchesSearch = product.productName.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = categoryFilter.isEmpty || categoryFilter.contains(product.category.id);
      final matchesBrand = brandFilter.isEmpty || brandFilter.contains(product.brand.id);
      return matchesSearch && matchesCategory && matchesBrand;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    products = fetchProducts(searchQuery, categoryFilter, brandFilter);
    log('Fetched products: ${products.map((p) => p.productName).join(', ')}');
  }

  Widget _buildExpandedContent() {
    if (searchOpen) {
      return _buildSearchContent();
    } else if (filterOpen) {
      return _buildFilterContent();
    } else if (sortOpen) {
      return _buildSortContent();
    }
    return const SizedBox.shrink();
  }

  Widget _expandedContainer({required List<Widget> contents})
  {
    return Container(
      color: Colors.blue[100],
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: contents,
      ), // temp for viewing boundaries
    );
  }

  Widget _buildSearchContent() {
    return _expandedContainer(
      contents: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search products...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              products = fetchProducts(searchQuery, categoryFilter, brandFilter);
            });
          },
        ),
      ],
    );
  }

  Widget _buildFilterContent() {
    return _expandedContainer(
      contents: [
        Text(
          'Filters',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Categories',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilterChip(
              label: const Text('Category 1'),
              selected: categoryFilter.contains('CAT1'),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    categoryFilter.add('CAT1');
                  } else {
                    categoryFilter.remove('CAT1');
                  }
                  products = fetchProducts(searchQuery, categoryFilter, brandFilter);
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Category 2'),
              selected: categoryFilter.contains('CAT2'),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    categoryFilter.add('CAT2');
                  } else {
                    categoryFilter.remove('CAT2');
                  }
                  products = fetchProducts(searchQuery, categoryFilter, brandFilter);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortContent() {
    return _expandedContainer(
      contents: [
        Text(
          'Sort by',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        RadioGroup<SortOption>(
          groupValue: sortOption,
          onChanged: (value) {
            setState(() {
              sortOption = value;
              products = sortProducts(products, sortOption);
            });
          },
          child: Column(
            children: [
              ListTile(title: Text('Newest Arrivals'), leading: Radio<SortOption>(value: SortOption.timeDesc)),
              ListTile(title: Text('Oldest Arrivals'), leading: Radio<SortOption>(value: SortOption.timeAsc)),
              ListTile(title: Text('Name: A-Z'), leading: Radio<SortOption>(value: SortOption.nameAsc)),
              ListTile(title: Text('Name: Z-A'), leading: Radio<SortOption>(value: SortOption.nameDesc)),
              ListTile(title: Text('Price: Low to High'), leading: Radio<SortOption>(value: SortOption.priceAsc)),
              ListTile(title: Text('Price: High to Low'), leading: Radio<SortOption>(value: SortOption.priceDesc)),
              ListTile(title: Text('Rating'), leading: Radio<SortOption>(value: SortOption.rating)),
            ],
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    
    bool isExpanded = searchOpen || filterOpen || sortOpen;
    
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
          Container(
            color: colorScheme.surface,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductListingItem(productListing: products[index]);
              },
            ),
          ),
          // Floating container above bottom bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              alignment: AlignmentDirectional.bottomCenter,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // color: Colors.amber[100], // temp color for visibility, replace with theme color
              child: isExpanded
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(), // add if needed
                        child: _buildExpandedContent(),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.red[100],//colorScheme.surface,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              // Text(
              //   'Showing ${testData.length} products',
              //   style: theme.textTheme.bodyLarge?.copyWith(
              //     color: colorScheme.onSurface,
              //   ),
              // ),
              IconButton(onPressed: () {
                setState(() {
                  filterOpen = !filterOpen;
                  searchOpen = false;
                  sortOpen = false;
                  products = fetchProducts(searchQuery, categoryFilter, brandFilter); // refetch products with new search and filters
                });
              }, icon: Icon(Icons.filter_list_alt)),
              IconButton(onPressed: () {
                setState(() {
                  searchOpen = !searchOpen;
                  filterOpen = false;
                  sortOpen = false;
                });
              }, icon: Icon(Icons.search)),
              IconButton(onPressed: () {
                setState(() {
                  sortOpen = !sortOpen;
                  searchOpen = false;
                  filterOpen = false;
                });
              }, icon: Icon(Icons.sort))
            ],
          ),
        ),
      ),
    );
  }
}