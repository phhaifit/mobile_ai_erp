import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/cart/models/cart_ui_model.dart';
import 'stock_warning_badge.dart';
import 'quantity_selector.dart';

/// Card widget displaying individual cart item
class CartItemCard extends StatelessWidget {
  final CartItemUIModel item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;
  final VoidCallback? onTap;
  final bool showStockWarning;
  final bool isSelected;
  final ValueChanged<bool>? onSelectChanged;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
    this.onTap,
    this.showStockWarning = true,
    this.isSelected = false,
    this.onSelectChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.blue[600]!, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox (optional)
                if (onSelectChanged != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) => onSelectChanged!(value ?? false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                // Product image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: item.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          ),
                        )
                      : _buildImagePlaceholder(),
                ),
                const SizedBox(width: 12),
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Text(
                        item.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Customization info
                      if (item.hasCustomization)
                        Text(
                          item.customizationLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Stock warning badge
                      if (showStockWarning)
                        StockWarningBadge(
                          isOutOfStock: item.isOutOfStock,
                          isLowStock: item.isLowStock,
                          availableStock: item.availableStock,
                          size: 12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Price and quantity row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.formattedTotalPrice,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              if (item.itemDiscount != null &&
                                  item.itemDiscount! > 0)
                                Text(
                                  '-${item.formattedDiscountAmount}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                          // Quantity selector
                          QuantitySelector(
                            currentQuantity: item.quantity,
                            maxQuantity: item.availableStock,
                            onQuantityChanged: onQuantityChanged,
                            size: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Remove button
                Column(
                  children: [
                    IconButton(
                      onPressed: onRemove,
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red[600],
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey[400],
      ),
    );
  }
}

/// Compact cart item card (minimal design)
class CompactCartItemCard extends StatelessWidget {
  final CartItemUIModel item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChanged;

  const CompactCartItemCard({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
                ),
              )
            : Icon(Icons.image, color: Colors.grey[400]),
      ),
      title: Text(
        item.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        item.formattedTotalPrice,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CompactQuantitySelector(
            currentQuantity: item.quantity,
            maxQuantity: item.availableStock,
            onChanged: onQuantityChanged,
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, color: Colors.red[600], size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
