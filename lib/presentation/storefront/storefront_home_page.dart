import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/brand_card.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/category_card.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/heading_section.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/page_banner.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_card_small.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class StorefrontHomePage extends StatefulWidget {
  const StorefrontHomePage({super.key});

  @override
  _StorefrontHomePageState createState() => _StorefrontHomePageState();
}

class _StorefrontHomePageState extends State<StorefrontHomePage> {
  String? imageSource;
  // bool isLoadingImageSource = true;

  List<Product> productsFeatured = List.empty();
  List<Product> productsNewArrivals = List.empty();
  List<Product> productsPopular = List.empty();
  List<Product> productsForYou = List.empty();
  List<Category> featuredCategories = List.empty();
  List<Brand> featuredBrands = List.empty();

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
        name: 'Electronics',
        code: 'ELEC',
        slug: 'electronics',
      ),
      Category(
        id: 'CAT2',
        name: 'Clothing',
        code: 'CLOTH',
        slug: 'clothing',
      ),
      Category(
        id: 'CAT3',
        name: 'Home & Garden',
        code: 'HOME',
        slug: 'home-garden',
      ),
    ];
  }

  List<Brand> fetchFeaturedBrands() {
    //// call repository here
    return [
      const Brand(
        id: 'BRAND1',
        name: 'TechCorp',
        code: 'BRAND1',
      ),
      const Brand(
        id: 'BRAND2',
        name: 'CompuTech',
        code: 'BRAND2',
      ),
      const Brand(
        id: 'BRAND3',
        name: 'FashionBrand',
        code: 'BRAND3',
      ),
    ];
  }

  List<Product> fetchMock() {
    return [
      Product(
      id: 'PT1',
      productName: 'Smile',
      category: Category(id: 'CAT1', name: 'Happy', code: 'CAT1', slug: 'happy'),
      brand: Brand(id: 'BRAND1', name: 'CLX', code: 'BRAND1'),
      rating: 5.0,
      price: 2000,
      currency: 'USD',
      imageSource: 'https://picsum.photos/id/17/250/250',
      ),
      Product(
        id: 'PT2',
        productName: 'Surprise',
        category: Category(id: 'CAT1', name: 'Happy', code: 'CAT1', slug: 'happy'),
        brand: Brand(id: 'BRAND2', name: 'MGMG', code: 'BRAND2'),
        rating: 4.0,
        price: 29.99,
        currency: 'USD',
        imageSource: null,
      ),
      Product(
        id: 'PT3',
        productName: 'Fresh Pro',
        category: Category(id: 'CAT2', name: 'General', code: 'CAT2', slug: 'general'),
        brand: Brand(id: 'BRAND2', name: 'MGMG', code: 'BRAND2'),
        rating: 1.0,
        price: 29.99,
        currency: 'USD',
        imageSource: 'https://picsum.photos/id/19/250/250',
      ),
      Product(
        id: 'PT4',
        productName: 'Super Item',
        category: Category(id: 'CAT2', name: 'General', code: 'CAT2', slug: 'general'),
        brand: Brand(id: 'BRAND3', name: 'SOUPS', code: 'BRAND3'),
        rating: 4.0,
        price: 40.50,
        currency: 'USD',
        imageSource: 'https://picsum.photos/id/20/250/250',
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
                headingText: "Featured"
              ),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Product product in productsFeatured) 
                    ProductCardSmall(
                      productId: product.id, 
                      productName: product.productName, 
                      imageSource: product.imageSource
                    )
                ],
              ),
              SectionHeader(
                headingText: "New Arrivals", 
                linkText: "See all", 
                linkDestination: Routes.storefrontProductListing, 
                filterArguments: FilterArguments(sortOption: SortOption.timeDesc),),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Product product in productsNewArrivals) 
                    ProductCardSmall(
                      productId: product.id, 
                      productName: product.productName, 
                      imageSource: product.imageSource
                    )
                ],
              ),
              SectionHeader(headingText: "Popular", linkText: "See all", linkDestination: Routes.storefrontProductListing, filterArguments: FilterArguments(sortOption: SortOption.popular)),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Product product in productsPopular) 
                    ProductCardSmall(
                      productId: product.id, 
                      productName: product.productName, 
                      imageSource: product.imageSource
                    )
                ],
              ),
              SectionHeader(headingText: "Featured Categories", linkText: "See all", linkDestination: Routes.categoriesLanding),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Category category in featuredCategories)
                    CategoryCard(category: category)
                ],
              ),
              SectionHeader(headingText: "Featured Brands", linkText: "See all", linkDestination: Routes.brandsLanding),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Brand brand in featuredBrands)
                    BrandCard(brand: brand)
                ],
              ),
              SectionHeader(headingText: "For You", linkText: "See all", linkDestination: Routes.storefrontProductListing, filterArguments: FilterArguments(sortOption: SortOption.relevance)),
              Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: [
                  for (final Product product in productsForYou) 
                    ProductCardSmall(
                      productId: product.id, 
                      productName: product.productName, 
                      imageSource: product.imageSource
                    )
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}