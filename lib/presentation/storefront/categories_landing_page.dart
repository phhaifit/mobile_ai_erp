import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product/product.dart';
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
  late List<Category> majorCategories;
  late Map<String, List<Product>> productsByCategory;
  late Map<String, List<Category>> subcategoriesByCategory;
  late Map<String, bool> expandedCategoriesState;

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
        brand:
            Brand(id: 'BRAND1', name: 'TechCorp', code: 'BRAND1'),
        rating: 5.0,
        price: 999.99,
        currency: 'USD',
        imageSource: 'https://picsum.photos/id/17/250/250',
      ),
      Product(
        id: 'PT2',
        productName: 'Laptop',
        category: Category(
          id: 'CAT1',
          name: 'Electronics',
          code: 'ELEC',
          slug: 'electronics',
        ),
        brand:
            Brand(id: 'BRAND2', name: 'CompuTech', code: 'BRAND2'),
        rating: 4.5,
        price: 1499.99,
        currency: 'USD',
        imageSource: 'https://picsum.photos/id/19/250/250',
      ),
      Product(
        id: 'PT3',
        productName: 'T-Shirt',
        category: Category(
          id: 'CAT2',
          name: 'Clothing',
          code: 'CLOTH',
          slug: 'clothing',
        ),
        brand: Brand(id: 'BRAND3', name: 'FashionBrand', code: 'BRAND3'),
        rating: 4.0,
        price: 29.99,
        currency: 'USD',
        imageSource: 'https://picsum.photos/id/20/250/250',
      ),
      Product(
        id: 'PT4',
        productName: 'Jeans',
        category: Category(
          id: 'CAT2',
          name: 'Clothing',
          code: 'CLOTH',
          slug: 'clothing',
        ),
        brand: Brand(id: 'BRAND3', name: 'FashionBrand', code: 'BRAND3'),
        rating: 4.2,
        price: 59.99,
        currency: 'USD',
        imageSource: 'https://picsum.photos/id/21/250/250',
      ),
    ];
  }

  Map<String, List<Product>> fetchProductsByCategory() {
    final products = fetchMockProducts();
    final result = <String, List<Product>>{};
    for (final category in majorCategories) {
      result[category.id] = products
          .where((p) => p.category.id == category.id)
          .toList();
    }
    return result;
  }

  Map<String, List<Category>> fetchSubcategoriesByCategory() {
    return {
      'CAT1': [
        Category(
          id: 'CAT1_1',
          name: 'Phones',
          code: 'PHONES',
          slug: 'phones',
          parentId: 'CAT1',
        ),
        Category(
          id: 'CAT1_2',
          name: 'Computers',
          code: 'COMPUTERS',
          slug: 'computers',
          parentId: 'CAT1',
        ),
        Category(
          id: 'CAT1_3',
          name: 'Accessories',
          code: 'ACCESSORIES',
          slug: 'accessories',
          parentId: 'CAT1',
        ),
      ],
      'CAT2': [
        Category(
          id: 'CAT2_1',
          name: 'Men',
          code: 'MEN',
          slug: 'men',
          parentId: 'CAT2',
        ),
        Category(
          id: 'CAT2_2',
          name: 'Women',
          code: 'WOMEN',
          slug: 'women',
          parentId: 'CAT2',
        ),
      ],
      'CAT3': [
        Category(
          id: 'CAT3_1',
          name: 'Furniture',
          code: 'FURNITURE',
          slug: 'furniture',
          parentId: 'CAT3',
        ),
        Category(
          id: 'CAT3_2',
          name: 'Garden Tools',
          code: 'GARDEN_TOOLS',
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
          filterArguments: FilterArguments(selectedCategories: [category.id]),
        ),
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
        Navigator.of(context).pushNamed(Routes.storefrontProductListing, arguments: FilterArguments(selectedCategories: [subcategory.id]));
      },
    );
  }
}
