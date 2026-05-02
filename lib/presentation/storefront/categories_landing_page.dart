import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/page_banner.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/storefront_ui.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class CategoriesLandingPage extends StatefulWidget {
  const CategoriesLandingPage({super.key});

  @override
  State<CategoriesLandingPage> createState() => _CategoriesLandingPageState();
}

class _CategoriesLandingPageState extends State<CategoriesLandingPage> {
  final StorefrontRepository _repository = getIt<StorefrontRepository>();
  late Future<List<StorefrontCategoryTreeNode>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _repository.getCategories();
  }

  Future<void> _reload() async {
    setState(() {
      _categoriesFuture = _repository.getCategories();
    });
    await _categoriesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.storeHome),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F4EF), Color(0xFFFBFBFA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<StorefrontCategoryTreeNode>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return StorefrontEmptyState(
                icon: Icons.category_outlined,
                title: 'Unable to load categories',
                message: snapshot.error.toString(),
                actionLabel: 'Retry',
                onPressed: _reload,
              );
            }

            final categories = snapshot.data ?? const [];
            if (categories.isEmpty) {
              return StorefrontEmptyState(
                icon: Icons.category_outlined,
                title: 'No categories available',
                message:
                    'The public storefront runtime did not return category navigation for this tenant.',
                actionLabel: 'Refresh',
                onPressed: _reload,
              );
            }

            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 28),
                children: [
                  const PageBanner(
                    imageSource: null,
                    heading: 'Category Navigation',
                    subheading:
                        'Browse the live category tree and jump into category-aware product discovery with breadcrumb support.',
                    tags: ['API breadcrumbs', 'Category tree'],
                  ),
                  for (final category in categories)
                    _buildCategorySection(context, category),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    StorefrontCategoryTreeNode category,
  ) {
    return StorefrontSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            headingText: category.name,
            subheadingText:
                category.description ??
                'Browse products from this category and its children.',
            linkText: 'View products',
            linkDestination: Routes.storefrontProductListing,
            filterArguments: FilterArguments(
              selectedCategories: [category.slug],
              categoryKey: category.slug,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                StorefrontTag(
                  label: 'Category slug: ${category.slug}',
                  icon: Icons.route_outlined,
                ),
                if (category.children.isNotEmpty)
                  StorefrontTag(
                    label: '${category.children.length} subcategories',
                    icon: Icons.account_tree_outlined,
                    backgroundColor: const Color(0xFFFCE7DF),
                  ),
              ],
            ),
          ),
          if (category.children.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: category.children
                    .map(
                      (child) => ActionChip(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        label: Text(child.name),
                        avatar: const Icon(
                          Icons.arrow_outward_rounded,
                          size: 16,
                        ),
                        onPressed: () => Navigator.of(context).pushNamed(
                          Routes.storefrontProductListing,
                          arguments: FilterArguments(
                            selectedCategories: [child.slug],
                            categoryKey: child.slug,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
