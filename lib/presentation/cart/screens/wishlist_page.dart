import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/cart/store/wishlist_store.dart';

import '../widgets/wishlist_item_card.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late final WishlistStore wishlistStore;
  late final CartStore cartStore;

  @override
  void initState() {
    super.initState();
    wishlistStore = getIt<WishlistStore>();
    cartStore = getIt<CartStore>();
    wishlistStore.loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: Observer(
        builder: (_) {
          if (wishlistStore.isLoading && wishlistStore.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wishlistStore.errorMessage != null &&
              wishlistStore.items.isEmpty) {
            return _buildErrorState(context, wishlistStore.errorMessage!);
          }

          if (wishlistStore.items.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: wishlistStore.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final item = wishlistStore.items[index];

              return WishlistItemCard(
                item: item,
                onMoveToCart: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  await cartStore.addToCart(
                    productId: item.productId,
                    variantId: item.variantId,
                    qty: 1,
                  );

                  if (!context.mounted) return;

                  messenger.clearSnackBars();

                  if (cartStore.errorMessage != null) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(cartStore.errorMessage!)),
                    );
                    return;
                  }

                  await wishlistStore.loadWishlist();

                  if (!context.mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(content: Text('Moved to cart')),
                  );
                },
                onRemove: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  await wishlistStore.removeFromWishlist(item);

                  if (!context.mounted) return;

                  messenger.clearSnackBars();

                  if (wishlistStore.errorMessage != null) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(wishlistStore.errorMessage!)),
                    );
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Removed from wishlist')),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Your wishlist is empty',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save items for later and they will appear here.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Could not load wishlist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => wishlistStore.loadWishlist(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
