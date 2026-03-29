import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/heading_section.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_card_small.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class BrandsLandingPage extends StatefulWidget {
  const BrandsLandingPage({super.key});

  @override
  State<BrandsLandingPage> createState() => _BrandsLandingPageState();
}

class _BrandsLandingPageState extends State<BrandsLandingPage> {
  late List<Brand> brands;
  late Map<String, List<Product>> productsByBrand;

  @override
  void initState() {
    super.initState();
    brands = fetchBrands();
    productsByBrand = fetchProductsByBrand();
  }

  List<Brand> fetchBrands() {
    return [
      const Brand(
        id: 'BRAND1',
        name: 'TechCorp',
        code: 'BRAND1',
        description: 'Leading technology innovator',
        countryCode: 'US',
        city: 'San Francisco',
      ),
      const Brand(
        id: 'BRAND2',
        name: 'CompuTech',
        code: 'BRAND2',
        description: 'Quality computing solutions',
        countryCode: 'JP',
        city: 'Tokyo',
      ),
      const Brand(
        id: 'BRAND3',
        name: 'FashionBrand',
        code: 'BRAND3',
        description: 'Trendy fashion for everyone',
        countryCode: 'IT',
        city: 'Milan',
      ),
      const Brand(
        id: 'BRAND4',
        name: 'HomeGoods',
        code: 'BRAND4',
        description: 'Quality home and garden products',
        countryCode: 'DE',
        city: 'Berlin',
      ),
    ];
  }

  List<Product> fetchMockProducts() {
    return [
      Product(
        id: 'PT1',
        productName: 'Smart Phone',
        category: Category(
          id: 'CAT1',
          name: 'Electronics',
          code: 'ELEC',
          slug: 'electronics',
        ),
        brand: const Brand(id: 'BRAND1', name: 'TechCorp', code: 'BRAND1'),
        rating: 5.0,
        price: 999.99,
        currency: 'USD',
        imageSource: 'https://picsum.photos/id/17/250/250',
      ),
      Product(
        id: 'PT2',
        productName: 'Tablet',
        category: Category(
          id: 'CAT1',
          name: 'Electronics',
          code: 'ELEC',
          slug: 'electronics',
        ),
        brand: const Brand(id: 'BRAND1', name: 'TechCorp', code: 'BRAND1'),
        rating: 4.8,
        price: 599.99,
        currency: 'USD',
        imageSource: 'https://picsum.photos/id/18/250/250',
      ),
      Product(
        id: 'PT3',
        productName: 'Laptop',
        category: Category(
          id: 'CAT1',
          name: 'Electronics',
          code: 'ELEC',
          slug: 'electronics',
        ),
        brand: const Brand(id: 'BRAND2', name: 'CompuTech', code: 'BRAND2'),
        rating: 4.5,
        price: 1499.99,
        currency: 'USD',
        imageSource: 'https://picsum.photos/id/19/250/250',
      ),
      Product(
        id: 'PT4',
        productName: 'Desktop Computer',
        category: Category(
          id: 'CAT1',
          name: 'Electronics',
          code: 'ELEC',
          slug: 'electronics',
        ),
        brand: const Brand(id: 'BRAND2', name: 'CompuTech', code: 'BRAND2'),
        rating: 4.3,
        price: 1999.99,
        currency: 'USD',
        imageSource: null,
      ),
      Product(
        id: 'PT5',
        productName: 'T-Shirt',
        category: Category(
          id: 'CAT2',
          name: 'Clothing',
          code: 'CLOTH',
          slug: 'clothing',
        ),
        brand: const Brand(id: 'BRAND3', name: 'FashionBrand', code: 'BRAND3'),
        rating: 4.0,
        price: 29.99,
        currency: 'USD',
        imageSource: 'https://picsum.photos/id/20/250/250',
      ),
      Product(
        id: 'PT6',
        productName: 'Jeans',
        category: Category(
          id: 'CAT2',
          name: 'Clothing',
          code: 'CLOTH',
          slug: 'clothing',
        ),
        brand: const Brand(id: 'BRAND3', name: 'FashionBrand', code: 'BRAND3'),
        rating: 4.2,
        price: 59.99,
        currency: 'USD',
        imageSource: 'https://picsum.photos/id/21/250/250',
      ),
    ];
  }

  Map<String, List<Product>> fetchProductsByBrand() {
    final products = fetchMockProducts();
    final result = <String, List<Product>>{};
    for (final brand in brands) {
      result[brand.id] =
          products.where((p) => p.brand.id == brand.id).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brands'),
        actions: [
          IconButton(onPressed: () => Navigator.of(context).pushNamed(Routes.storeHome), icon: Icon(Icons.home))
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              for (final brand in brands) _buildBrandSection(context, brand),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context, Brand brand) {
    final products = productsByBrand[brand.id] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          headingText: brand.name,
          linkText: "See all products from ${brand.name}",
          linkDestination: Routes.storefrontProductListing,
          filterArguments: FilterArguments(selectedBrands: [brand.id]),
        ),
        if (brand.description != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              brand.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
        if (brand.displayLocation != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 5.0),
                Text(
                  brand.displayLocation!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        const SizedBox(height: 10.0),
        if (products.isNotEmpty)
          Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: [
              for (final product in products)
                ProductCardSmall(
                  productId: product.id,
                  productName: product.productName,
                  imageSource: product.imageSource,
                )
            ],
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'No products available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
