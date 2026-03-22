import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/cart/models/cart_ui_model.dart';
import 'price_summary_card.dart';

/// Mini cart drawer widget for quick cart preview
class MiniCartDrawer extends StatelessWidget {
  final CartUIModel cartData;
  final VoidCallback onViewFullCart;
  final VoidCallback onCheckout;
  final Function(String) onRemoveItem;
  final Function(String, int) onQuantityChanged;
  final bool isLoading;
  final bool isDrawerOpen;
  final VoidCallback onDrawerToggle;

  const MiniCartDrawer({
    Key? key,
    required this.cartData,
    required this.onViewFullCart,
    required this.onCheckout,
    required this.onRemoveItem,
    required this.onQuantityChanged,
    this.isLoading = false,
    this.isDrawerOpen = false,
    required this.onDrawerToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildDrawerHeader(context),
            // Divider
            Divider(color: Colors.grey[200]),
            // Cart items list
            Expanded(
              child: _buildCartItemsList(context),
            ),
            // Divider
            Divider(color: Colors.grey[200]),
            // Price summary
            _buildPriceSummary(context),
            // Checkout button
            _buildCheckoutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Cart',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${cartData.itemCount} item${cartData.itemCount != 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(BuildContext context) {
    if (cartData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onViewFullCart();
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: cartData.items.length,
      itemBuilder: (context, index) {
        final item = cartData.items[index];
        return _buildMiniCartItem(context, item);
      },
    );
  }

  Widget _buildMiniCartItem(BuildContext context, CartItemUIModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[100],
            ),
            child: item.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image, color: Colors.grey[400]),
                    ),
                  )
                : Icon(Icons.image, color: Colors.grey[400]),
          ),
          title: Text(
            item.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          subtitle: Row(
            children: [
              Text('Qty: ${item.quantity}'),
              const SizedBox(width: 8),
              Text(
                item.formattedTotalPrice,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          trailing: SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: item.quantity > 1
                      ? () => onQuantityChanged(item.id, item.quantity - 1)
                      : null,
                  child: Icon(
                    Icons.remove_circle_outline,
                    size: 16,
                    color: item.quantity > 1 ? Colors.blue : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: item.canIncreaseQuantity
                      ? () => onQuantityChanged(item.id, item.quantity + 1)
                      : null,
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 16,
                    color: item.canIncreaseQuantity ? Colors.blue : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => onRemoveItem(item.id),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CompactPriceSummary(
        subtotal: cartData.subtotal,
        total: cartData.total,
        itemCount: cartData.itemCount,
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                onViewFullCart();
              },
              child: const Text('View Full Cart'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini cart badge (cart icon with item count)
class MiniCartBadge extends StatelessWidget {
  final int itemCount;
  final VoidCallback onTap;
  final bool hasDiscount;

  const MiniCartBadge({
    Key? key,
    required this.itemCount,
    required this.onTap,
    this.hasDiscount = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: hasDiscount ? Colors.green[600] : Colors.blue[600],
          ),
          onPressed: onTap,
        ),
        if (itemCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red[600],
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  itemCount > 99 ? '99+' : itemCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
