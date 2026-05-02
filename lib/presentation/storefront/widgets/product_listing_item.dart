import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:mobile_ai_erp/presentation/storefront/models/storefront_models.dart';
import 'package:mobile_ai_erp/presentation/storefront/widgets/storefront_ui.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

/// Widget for a product shown in homepage, product listing page (with or without search/filters), brand and collection landing pages
///
/// Product information provided by parent widget
class ProductListingItem extends StatelessWidget {
  const ProductListingItem({
    super.key,
    required this.productListing,
    this.highlightText,
  });

  final StorefrontProduct productListing;
  final String? highlightText;

  @override
  Widget build(BuildContext context) {
    var highlightedWords = <String, HighlightedWord>{};
    if (highlightText != null && highlightText!.isNotEmpty) {
      highlightedWords = {
        highlightText!: HighlightedWord(
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF241E30),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD66B),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      };
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imageSize = MediaQuery.of(context).size.width >= 960 ? 180.0 : 132.0;
    final hasDiscount =
        productListing.originalPrice != null &&
        productListing.originalPrice! > productListing.price;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.24),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(Routes.productDetail, arguments: productListing.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  StorefrontNetworkImage(
                    imageUrl: productListing.images.isNotEmpty
                        ? productListing.images.first
                        : null,
                    width: imageSize,
                    height: imageSize,
                    borderRadius: BorderRadius.circular(22),
                    icon: Icons.inventory_2_outlined,
                  ),
                  if (productListing.isFlashSale)
                    const Positioned(
                      top: 10,
                      left: 10,
                      child: StorefrontTag(
                        label: 'Flash sale',
                        icon: Icons.bolt,
                        backgroundColor: Color(0xFFD21E1D),
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextHighlight(
                      text: productListing.title,
                      words: highlightedWords,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        height: 1.35,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if ((productListing.category ?? '').isNotEmpty)
                          StorefrontTag(
                            label: productListing.category!,
                            icon: Icons.category_outlined,
                          ),
                        if ((productListing.brand ?? '').isNotEmpty)
                          StorefrontTag(
                            label: productListing.brand!,
                            icon: Icons.workspace_premium_outlined,
                            backgroundColor: const Color(0xFFFCE7DF),
                          ),
                        StorefrontTag(
                          label: productListing.inStock
                              ? 'In stock'
                              : 'Out of stock',
                          icon: productListing.inStock
                              ? Icons.check_circle_outline
                              : Icons.remove_shopping_cart_outlined,
                          backgroundColor: productListing.inStock
                              ? const Color(0xFFE6F6EC)
                              : const Color(0xFFFFE7E4),
                          foregroundColor: productListing.inStock
                              ? const Color(0xFF0B7A44)
                              : const Color(0xFFD21E1D),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          productListing.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${productListing.availableStock} available',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if ((productListing.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      TextHighlight(
                        text: productListing.description ?? '',
                        words: highlightedWords,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textStyle: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                storefrontCurrency(productListing.price),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: colorScheme.primary,
                                ),
                              ),
                              if (hasDiscount)
                                Text(
                                  storefrontCurrency(
                                    productListing.originalPrice!,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              Routes.productDetail,
                              arguments: productListing.id,
                            );
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('View'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
