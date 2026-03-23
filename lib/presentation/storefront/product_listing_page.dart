import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/storefront/product_listing_item.dart';

class ProductListingScreen extends StatefulWidget {
  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  @override
  Widget build(BuildContext context) {
    List<Product> testData = [
      Product(
        id: 'PT1',
        productName: 'Product 1',
        category: Category(id: 'CAT1', name: 'Category 1', code: 'CAT1', slug: 'category-1'),
        brand: Brand(id: 'BRAND1', name: 'Brand A', code: 'BRAND1', ),
        rating: 4.5,
        price: 19.99,
        currency: 'USD',
        imageSource: 'https://picsum.photos/250?image=2',
      ),
      Product(
        id: 'PT2',
        productName: 'Product 2',
        category: Category(id: 'CAT2', name: 'Category 2', code: 'CAT2', slug: 'category-2'),
        brand: Brand(id: 'BRAND2', name: 'Brand B', code: 'BRAND2'),
        rating: 4.0,
        price: 29.99,
        currency: 'USD',
        imageSource: null, // No image source provided
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Products'),
      ),
      body: ListView.builder(
        itemCount: testData.length,
        itemBuilder: (context, index) {
          return ProductListingItem(productListing: testData[index]);
        },
      ),
    );
  }
}