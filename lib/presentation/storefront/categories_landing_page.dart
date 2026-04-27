import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.storeHome),
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: FutureBuilder<List<StorefrontCategoryTreeNode>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final categories = snapshot.data ?? const [];
          return ListView(
            children: [
              const SizedBox(height: 20),
              for (final category in categories) _buildCategorySection(category),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(StorefrontCategoryTreeNode category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          headingText: category.name,
          linkText: 'See all ${category.name}',
          linkDestination: Routes.storefrontProductListing,
          filterArguments: FilterArguments(
            selectedCategories: [category.id],
            categoryKey: category.slug,
          ),
        ),
        if (category.description != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(category.description!),
          ),
        if (category.children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: category.children
                  .map(
                    (child) => ActionChip(
                      label: Text(child.name),
                      onPressed: () => Navigator.of(context).pushNamed(
                        Routes.storefrontProductListing,
                        arguments: FilterArguments(
                          selectedCategories: [child.id],
                          categoryKey: child.slug,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}
