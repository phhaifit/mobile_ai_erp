import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/page_banner.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_card_small.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/storefront_ui.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class CollectionsLandingPage extends StatefulWidget {
  const CollectionsLandingPage({super.key});

  @override
  State<CollectionsLandingPage> createState() => _CollectionsLandingPageState();
}

class _CollectionsLandingPageState extends State<CollectionsLandingPage> {
  final StorefrontRepository _repository = getIt<StorefrontRepository>();
  late Future<List<StorefrontCollection>> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _collectionsFuture = _repository.getCollections();
  }

  Future<void> _reload() async {
    setState(() {
      _collectionsFuture = _repository.getCollections();
    });
    await _collectionsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
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
        child: FutureBuilder<List<StorefrontCollection>>(
          future: _collectionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return StorefrontEmptyState(
                icon: Icons.layers_outlined,
                title: 'Unable to load collections',
                message: snapshot.error.toString(),
                actionLabel: 'Retry',
                onPressed: _reload,
              );
            }

            final collections = snapshot.data ?? const [];
            if (collections.isEmpty) {
              return StorefrontEmptyState(
                icon: Icons.layers_outlined,
                title: 'No collections available',
                message:
                    'The public storefront runtime did not return collection data for this tenant.',
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
                    heading: 'Collection Landings',
                    subheading:
                        'Curated collection pages backed by live storefront data and connected product listing filters.',
                    tags: ['Curated discovery', 'Live collection data'],
                  ),
                  for (final collection in collections)
                    _buildCollectionSection(context, collection),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCollectionSection(
    BuildContext context,
    StorefrontCollection collection,
  ) {
    return StorefrontSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            headingText: collection.name,
            subheadingText:
                collection.description ?? 'Discover this curated collection.',
            linkText: 'View collection',
            linkDestination: Routes.storefrontProductListing,
            filterArguments: FilterArguments(collectionSlug: collection.slug),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                StorefrontTag(
                  label: '${collection.productCount} items',
                  icon: Icons.inventory_2_outlined,
                ),
                StorefrontTag(
                  label: 'Slug: ${collection.slug}',
                  icon: Icons.bookmark_outline,
                  backgroundColor: const Color(0xFFFCE7DF),
                ),
              ],
            ),
          ),
          if (collection.featuredProducts.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: collection.featuredProducts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = collection.featuredProducts[index];
                  return ProductCardSmall(
                    productId: product.id,
                    productName: product.title,
                    imageSource: product.images.isNotEmpty
                        ? product.images.first
                        : null,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
