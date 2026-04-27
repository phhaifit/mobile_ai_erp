import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/brand_card.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/category_card.dart';
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
  static final DateTime _mockTimestamp = DateTime(2026, 4, 10);
  String? imageSource;
  // bool isLoadingImageSource = true;

  List<Product> productsFeatured = List.empty();
  List<Product> productsNewArrivals = List.empty();
  List<Product> productsPopular = List.empty();
  List<Product> productsForYou = List.empty();
  List<Category> featuredCategories = List.empty();
  List<Brand> featuredBrands = List.empty();

  Brand _brand(String id, String name) {
    return Brand(
      id: id,
      tenantId: 'tenant_demo',
      name: name,
      createdAt: _mockTimestamp,
      updatedAt: _mockTimestamp,
    );
  }

  Category _category({
    required String id,
    required String name,
    required String slug,
    String? parentId,
  }) {
    return Category(
      id: id,
      tenantId: 'tenant_demo',
      name: name,
      slug: slug,
      parentId: parentId,
      createdAt: _mockTimestamp,
      updatedAt: _mockTimestamp,
    );
  }

  String fetchBannerImageSource() {
    //// call repository here
    return "https://picsum.photos/id/200/800/400";
  }

  List<Product> fetchFeaturedProducts() {
    //// call repository here
    return fetchMock();
  }
  List<Product> fetchNewArrivals() {
    //// call repository here
    return fetchMock();
  }
  List<Product> fetchPopular() {
    //// call repository here
    return fetchMock();
  }
  List<Product> fetchForYou() {
    //// call repository here
    return fetchMock();
  }

  List<Category> fetchFeaturedCategories() {
    //// call repository here
    return [
      Category(
        id: 'CAT1',
        tenantId: 'tenant_demo',
        name: 'Electronics',
        slug: 'electronics',
        createdAt: _mockTimestamp,
        updatedAt: _mockTimestamp,
      ),
      Category(
        id: 'CAT2',
        tenantId: 'tenant_demo',
        name: 'Clothing',
        slug: 'clothing',
        createdAt: _mockTimestamp,
        updatedAt: _mockTimestamp,
      ),
      Category(
        id: 'CAT3',
        tenantId: 'tenant_demo',
        name: 'Home & Garden',
        slug: 'home-garden',
        createdAt: _mockTimestamp,
        updatedAt: _mockTimestamp,
      ),
    ];
  }

  List<Brand> fetchFeaturedBrands() {
    //// call repository here
    return [
      _brand('BRAND1', 'TechCorp'),
      _brand('BRAND2', 'CompuTech'),
      _brand('BRAND3', 'FashionBrand'),
    ];
  }

  List<Product> fetchMock() {
    return [
      Product(
        id: 1,
        name: 'Smile',
        sku: 'SMILE-001',
        price: 2000.0,
        currency: 'USD',
        rating: 5.0,
        description: 'Premium smile product for happy customers',
        status: ProductStatus.ACTIVE,
        categoryId: 1,
        brandId: 1,
        tagIds: [1],
        imageUrls: ['https://picsum.photos/id/17/250/250'],
        category: _category(id: 'CAT1', name: 'Happy', slug: 'happy'),
        brand: _brand('BRAND1', 'CLX'),
      ),
      Product(
        id: 2,
        name: 'Surprise',
        sku: 'SURPRISE-001',
        price: 29.99,
        currency: 'USD',
        rating: 4.0,
        description: 'Amazing surprise product that delights customers',
        status: ProductStatus.ACTIVE,
        categoryId: 1,
        brandId: 2,
        tagIds: [1, 2],
        imageUrls: [],
        category: _category(id: 'CAT1', name: 'Happy', slug: 'happy'),
        brand: _brand('BRAND2', 'MGMG'),
      ),
      Product(
        id: 3,
        name: 'Fresh Pro',
        sku: 'FRESH-PRO-001',
        price: 29.99,
        currency: 'USD',
        rating: 1.0,
        description: 'Professional fresh product for everyday use',
        status: ProductStatus.ACTIVE,
        categoryId: 2,
        brandId: 2,
        tagIds: [2, 3],
        imageUrls: ['https://picsum.photos/id/19/250/250'],
        category: _category(id: 'CAT2', name: 'General', slug: 'general'),
        brand: _brand('BRAND2', 'MGMG'),
      ),
      Product(
        id: 4,
        name: 'Super Item',
        sku: 'SUPER-ITEM-001',
        price: 40.50,
        currency: 'USD',
        rating: 4.0,
        description: 'Super quality item for superior performance',
        status: ProductStatus.ACTIVE,
        categoryId: 2,
        brandId: 3,
        tagIds: [3],
        imageUrls: ['https://picsum.photos/id/20/250/250'],
        category: _category(id: 'CAT2', name: 'General', slug: 'general'),
        brand: _brand('BRAND3', 'SOUPS'),
      ),
    ].toList();
  }


  @override
  void initState() {
    super.initState();
    imageSource = fetchBannerImageSource();
    productsFeatured = fetchFeaturedProducts();
    productsNewArrivals = fetchNewArrivals();
    productsPopular = fetchPopular();
    productsForYou = fetchForYou();
    featuredCategories = fetchFeaturedCategories();
    featuredBrands = fetchFeaturedBrands();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Storefront Homepage')),
      body: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              PageBanner(imageSource: imageSource, heading: "Welcome"), // or replace with store name
              SizedBox(height: 20.0),
              SectionHeader(
                headingText: "Featured",
                linkText: "See all products",
                linkDestination: Routes.storefrontProductListing,
              ),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Product product in productsFeatured) 
                    ProductCardSmall(
                      productId: product.id, 
                      productName: product.name, 
                      imageSource: product.imageUrls.isNotEmpty ? product.imageUrls[0] : null
                    )
                ],
              ),
              SectionHeader(
                headingText: "For You", 
                linkText: "See all", 
                linkDestination: Routes.storefrontProductListing, 
                filterArguments: FilterArguments(sortOption: SortOption.relevance, selectedCategories: [], selectedBrands: [], searchQuery: "")
              ),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Product product in productsForYou) 
                    ProductCardSmall(
                      productId: product.id, 
                      productName: product.name, 
                      imageSource: product.imageUrls.isNotEmpty ? product.imageUrls[0] : null
                    )
                ],
              ),
              SectionHeader(
                headingText: "New Arrivals", 
                linkText: "See newest products", 
                linkDestination: Routes.storefrontProductListing, 
                filterArguments: FilterArguments(sortOption: SortOption.timeDesc)
              ),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Product product in productsNewArrivals) 
                    ProductCardSmall(
                      productId: product.id, 
                      productName: product.name, 
                      imageSource: product.imageUrls.isNotEmpty ? product.imageUrls[0] : null
                    )
                ],
              ),
              SectionHeader(
                headingText: "Popular", 
                linkText: "See all popular products", 
                linkDestination: Routes.storefrontProductListing, 
                filterArguments: FilterArguments(sortOption: SortOption.popular, selectedCategories: [], selectedBrands: [])
              ),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Product product in productsPopular) 
                    ProductCardSmall(
                      productId: product.id, 
                      productName: product.name, 
                      imageSource: product.imageUrls.isNotEmpty ? product.imageUrls[0] : null
                    )
                ],
              ),
              SectionHeader(
                headingText: "Featured Categories", 
                linkText: "See all categories", 
                linkDestination: Routes.categoriesLanding),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Category category in featuredCategories)
                    CategoryCard(category: category)
                ],
              ),
              SectionHeader(
                headingText: "Featured Brands", 
                linkText: "See all brands", 
                linkDestination: Routes.brandsLanding),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Brand brand in featuredBrands)
                    BrandCard(brand: brand)
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}