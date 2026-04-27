import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
import 'package:mobile_ai_erp/domain/entity/product/product_status.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_card_small.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class CategoriesLandingPage extends StatefulWidget {
  const CategoriesLandingPage({super.key});

  @override
  State<CategoriesLandingPage> createState() => _CategoriesLandingPageState();
}

class _CategoriesLandingPageState extends State<CategoriesLandingPage> {
  static final DateTime _mockTimestamp = DateTime(2026, 4, 10);
  late List<Category> majorCategories;
  late Map<String, List<Product>> productsByCategory;
  late Map<String, List<Category>> subcategoriesByCategory;
  late Map<String, bool> expandedCategoriesState;

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

  @override
  void initState() {
    super.initState();
    majorCategories = fetchMajorCategories();
    productsByCategory = fetchProductsByCategory();
    subcategoriesByCategory = fetchSubcategoriesByCategory();
    expandedCategoriesState = {};
  }

  List<Category> fetchMajorCategories() {
    return [
      _category(id: 'CAT1', name: 'Electronics', slug: 'electronics'),
      _category(id: 'CAT2', name: 'Clothing', slug: 'clothing'),
      _category(id: 'CAT3', name: 'Home & Garden', slug: 'home-garden'),
    ];
  }

  List<Product> fetchMockProducts() {
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

  Map<String, List<Product>> fetchProductsByCategory() {
    final products = fetchMockProducts();
    final result = <String, List<Product>>{};
    for (final category in majorCategories) {
      result[category.id] = products
          .where((p) => (p.category != null && p.category!.id == category.id))
          .toList();
    }
    return result;
  }

  Map<String, List<Category>> fetchSubcategoriesByCategory() {
    return {
      'CAT1': [
        _category(id: 'CAT1_1', name: 'Phones', slug: 'phones', parentId: 'CAT1'),
        _category(
          id: 'CAT1_2',
          name: 'Computers',
          slug: 'computers',
          parentId: 'CAT1',
        ),
        _category(
          id: 'CAT1_3',
          name: 'Accessories',
          slug: 'accessories',
          parentId: 'CAT1',
        ),
      ],
      'CAT2': [
        _category(id: 'CAT2_1', name: 'Men', slug: 'men', parentId: 'CAT2'),
        _category(id: 'CAT2_2', name: 'Women', slug: 'women', parentId: 'CAT2'),
      ],
      'CAT3': [
        _category(
          id: 'CAT3_1',
          name: 'Furniture',
          slug: 'furniture',
          parentId: 'CAT3',
        ),
        _category(
          id: 'CAT3_2',
          name: 'Garden Tools',
          slug: 'garden-tools',
          parentId: 'CAT3',
        ),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
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
              for (final category in majorCategories)
                _buildCategorySection(context, category),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, Category category) {
    final products = productsByCategory[category.id] ?? [];
    final subcategories = subcategoriesByCategory[category.id] ?? [];
    final isExpanded = expandedCategoriesState[category.id] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          headingText: category.name,
          linkText: 'See all ${category.name}',
          linkDestination: Routes.storefrontProductListing,
          filterArguments: FilterArguments(selectedCategories: [category.id], selectedBrands: [], searchQuery: ""),
        ),
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
          ),
        if (subcategories.isNotEmpty) ...[
          const SizedBox(height: 15.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subcategories',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    for (int i = 0;
                        i < (isExpanded ? subcategories.length : 3);
                        i++)
                      if (i < subcategories.length)
                        _buildSubcategoryChip(
                          context,
                          subcategories[i],
                        )
                  ],
                ),
                if (subcategories.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          expandedCategoriesState[category.id] = !isExpanded;
                        });
                      },
                      icon: Icon(isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more),
                      label: Text(isExpanded ? 'Show less' : 'Show more'),
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildSubcategoryChip(
    BuildContext context,
    Category subcategory,
  ) {
    return ActionChip(
      label: Text(subcategory.name),
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.storefrontProductListing, arguments: FilterArguments(selectedCategories: [subcategory.id], selectedBrands: [], searchQuery: ""));
      },
    );
  }
}
