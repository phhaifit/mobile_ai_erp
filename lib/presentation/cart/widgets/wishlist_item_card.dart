import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/price_formatter.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';

class WishlistItemCard extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback onMoveToCart;
  final VoidCallback onRemove;

  const WishlistItemCard({
    super.key,
    required this.item,
    required this.onMoveToCart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.thumbnailUrl ?? '';
    final inStock = item.isAvailable;
    final hasOriginalPrice =
        item.originalPrice != null &&
        item.originalPrice!.isNotEmpty &&
        item.originalPrice != item.sellingPrice;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 84,
                height: 84,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if ((item.variantSummary ?? '').isNotEmpty)
                    Text(
                      item.variantSummary!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  if (item.attributes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: item.attributes.map((attr) {
                        return Text(
                          '${attr.label}: ${attr.value}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    PriceFormatter.formatPrice(
                      double.tryParse(item.sellingPrice) ?? 0,
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (hasOriginalPrice) ...[
                    const SizedBox(height: 4),
                    Text(
                      PriceFormatter.formatPrice(
                        double.tryParse(item.originalPrice!) ?? 0,
                      ),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    inStock ? 'In stock' : 'Out of stock',
                    style: TextStyle(
                      color: inStock ? Colors.green[700] : Colors.red[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: inStock ? onMoveToCart : null,
                          child: const Text('Move to Cart'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
