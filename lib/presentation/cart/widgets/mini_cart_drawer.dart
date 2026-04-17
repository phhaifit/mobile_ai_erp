import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/price_formatter.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_calculation.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/presentation/cart/models/cart_ui_model.dart';
import 'price_summary_card.dart';

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

  static const Color _accentRed = Color(0xFFC63D2F);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            Divider(color: Colors.grey[200]),
            Expanded(child: _buildCartItemsList(context)),
            Divider(color: Colors.grey[200]),
            _buildPriceSummary(context),
            _buildCheckoutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final itemCount = cartData.cart.totalItems;

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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '$itemCount item${itemCount != 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          Tooltip(
            message: 'Close cart',
            child: IconButton(
              icon: const Icon(Icons.close),
              color: _accentRed,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(BuildContext context) {
    if (cartData.cart.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Colors.grey[300],
            ),
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
      itemCount: cartData.cart.items.length,
      itemBuilder: (context, index) {
        final item = cartData.cart.items[index];
        return _buildMiniCartItem(context, item);
      },
    );
  }

  Widget _buildMiniCartItem(BuildContext context, CartItem item) {
    final imageUrl = item.thumbnailUrl ?? '';
    final canIncreaseQuantity =
        item.isAvailable && item.quantity < item.availableStock;
    final subtitleParts = <String>['Qty: ${item.quantity}'];

    if ((item.variantSummary ?? '').isNotEmpty) {
      subtitleParts.add(item.variantSummary!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[100],
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image, color: Colors.grey[400]),
                    ),
                  )
                : Icon(Icons.image, color: Colors.grey[400]),
          ),
          title: Text(
            item.productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitleParts.join(' • ')),
              const SizedBox(height: 2),
              Text(
                PriceFormatter.formatPrice(
                  double.tryParse(item.lineTotal) ?? 0,
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          trailing: SizedBox(
            width: 92,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: 'Decrease quantity',
                  child: GestureDetector(
                    onTap: item.quantity > 1
                        ? () => onQuantityChanged(item.id, item.quantity - 1)
                        : null,
                    child: Icon(
                      Icons.remove_circle_outline,
                      size: 18,
                      color: item.quantity > 1 ? _accentRed : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Increase quantity',
                  child: GestureDetector(
                    onTap: canIncreaseQuantity
                        ? () => onQuantityChanged(item.id, item.quantity + 1)
                        : null,
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: canIncreaseQuantity ? _accentRed : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Remove from cart',
                  child: GestureDetector(
                    onTap: () => onRemoveItem(item.id),
                    child: const Icon(Icons.close, size: 18, color: _accentRed),
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
    final CartCalculationSummary summary =
        cartData.calculation?.summary ??
        CartCalculationSummary(
          subtotal: cartData.cart.subtotal,
          discount: '0',
          total: cartData.cart.subtotal,
          selectedItemsCount: cartData.cart.items.length,
          selectedQuantity: cartData.cart.totalItems,
        );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CompactPriceSummary(summary: summary),
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

  static const Color _accentRed = Color(0xFFC63D2F);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: hasDiscount ? 'Cart has discount' : 'Cart Page',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: _accentRed),
            iconSize: 24,
            hoverColor: _accentRed.withValues(alpha: 0.1),
            highlightColor: _accentRed.withValues(alpha: 0.1),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            onPressed: onTap,
          ),
          if (itemCount > 0)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _accentRed,
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
      ),
    );
  }
}
