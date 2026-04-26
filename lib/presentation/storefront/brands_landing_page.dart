import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
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
        id: 1,
        name: 'Smart Phone',
        sku: 'PHONE-001',
        price: 999.99,
        currency: 'USD',
        rating: 5.0,
        description: 'Latest smart phone with advanced features',
        status: ProductStatus.ACTIVE,
        categoryId: "1",
        brandId: "1",
        tagIds: [1, 2],
        imageUrls: ['https://picsum.photos/id/17/250/250'],
        category: Category(
          id: 'CAT1',
          name: 'Electronics',
          code: 'ELEC',
          slug: 'electronics',
        ),
        brand: const Brand(id: 'BRAND1', name: 'TechCorp', code: 'BRAND1'),
      ),
      Product(
        id: 2,
        name: 'Tablet',
        sku: 'TABLET-001',
        price: 599.99,
        currency: 'USD',
        rating: 4.8,
        description: 'High-performance tablet for work and entertainment',
        status: ProductStatus.ACTIVE,
        categoryId: "1",
        brandId: "1",
        tagIds: [1, 3],
        imageUrls: ['https://picsum.photos/id/18/250/250'],
        category: Category(
          id: 'CAT1',
          name: 'Electronics',
          code: 'ELEC',
          slug: 'electronics',
        ),
        brand: const Brand(id: 'BRAND1', name: 'TechCorp', code: 'BRAND1'),
      ),
      Product(
        id: 3,
        name: 'Laptop',
        sku: 'LAPTOP-001',
        price: 1499.99,
        currency: 'USD',
        rating: 4.5,
        description: 'Powerful laptop for professionals',
        status: ProductStatus.ACTIVE,
        categoryId: "1",
        brandId: "2",
        tagIds: [1, 2, 3],
        imageUrls: ['https://picsum.photos/id/19/250/250'],
        category: Category(
          id: 'CAT1',
          name: 'Electronics',
          code: 'ELEC',
          slug: 'electronics',
        ),
        brand: const Brand(id: 'BRAND2', name: 'CompuTech', code: 'BRAND2'),
      ),
      Product(
        id: 4,
        name: 'Desktop Computer',
        sku: 'DESKTOP-001',
        price: 1999.99,
        currency: 'USD',
        rating: 4.3,
        description: 'High-end desktop computer for gaming and work',
        status: ProductStatus.ACTIVE,
        categoryId: "1",
        brandId: "2",
        tagIds: [1, 4],
        imageUrls: [],
        category: Category(
          id: 'CAT1',
          name: 'Electronics',
          code: 'ELEC',
          slug: 'electronics',
        ),
        brand: const Brand(id: 'BRAND2', name: 'CompuTech', code: 'BRAND2'),
      ),
      Product(
        id: 5,
        name: 'T-Shirt',
        sku: 'TSHIRT-001',
        price: 29.99,
        currency: 'USD',
        rating: 4.0,
        description: 'Comfortable casual t-shirt',
        status: ProductStatus.ACTIVE,
        categoryId: "2",
        brandId: "3",
        tagIds: [5, 6],
        imageUrls: ['https://picsum.photos/id/20/250/250'],
        category: Category(
          id: 'CAT2',
          name: 'Clothing',
          code: 'CLOTH',
          slug: 'clothing',
        ),
        brand: const Brand(id: 'BRAND3', name: 'FashionBrand', code: 'BRAND3'),
      ),
      Product(
        id: 6,
        name: 'Jeans',
        sku: 'JEANS-001',
        price: 59.99,
        currency: 'USD',
        rating: 4.2,
        description: 'Classic denim jeans for everyday wear',
        status: ProductStatus.ACTIVE,
        categoryId: "2",
        brandId: "3",
        tagIds: [5, 6, 7],
        imageUrls: ['https://picsum.photos/id/21/250/250'],
        category: Category(
          id: 'CAT2',
          name: 'Clothing',
          code: 'CLOTH',
          slug: 'clothing',
        ),
        brand: const Brand(id: 'BRAND3', name: 'FashionBrand', code: 'BRAND3'),
      ),
    ];
  }

  Map<String, List<Product>> fetchProductsByBrand() {
    final products = fetchMockProducts();
    final result = <String, List<Product>>{};
    for (final brand in brands) {
      result[brand.id] =
          products.where((p) => (p.brand != null && p.brand!.id == brand.id)).toList();
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
          filterArguments: FilterArguments(selectedBrands: [brand.id], selectedCategories: [], searchQuery: ""),
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
                  productName: product.name,
                  imageSource: product.imageUrls.isNotEmpty ? product.imageUrls[0] : null,
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
