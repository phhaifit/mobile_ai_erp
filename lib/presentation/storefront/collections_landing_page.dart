import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/presentation/storefront/classes/filter_arguments.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/product_card_small.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/section_header.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(Routes.storeHome),
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: FutureBuilder<List<StorefrontCollection>>(
        future: _collectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _StorefrontAsyncState(
              message: snapshot.error.toString(),
              actionLabel: 'Retry',
              onPressed: () {
                setState(() {
                  _collectionsFuture = _repository.getCollections();
                });
              },
            );
          }
          final collections = snapshot.data ?? const [];
          if (collections.isEmpty) {
            return _StorefrontAsyncState(
              message:
                  'No storefront collections are currently available from the public runtime.',
              actionLabel: 'Refresh',
              onPressed: () {
                setState(() {
                  _collectionsFuture = _repository.getCollections();
                });
              },
            );
          }
          return ListView(
            children: [
              const SizedBox(height: 20),
              for (final collection in collections)
                _buildCollectionSection(context, collection),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCollectionSection(
    BuildContext context,
    StorefrontCollection collection,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          headingText: collection.name,
          linkText: 'See all in ${collection.name}',
          linkDestination: Routes.storefrontProductListing,
          filterArguments: FilterArguments(collectionSlug: collection.slug),
        ),
        if (collection.description != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(collection.description!),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text('${collection.productCount} products available'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: collection.featuredProducts
                .map(
                  (product) => ProductCardSmall(
                    productId: product.id,
                    productName: product.title,
                    imageSource: product.images.isNotEmpty
                        ? product.images.first
                        : null,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _StorefrontAsyncState extends StatelessWidget {
  const _StorefrontAsyncState({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.layers_outlined, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
