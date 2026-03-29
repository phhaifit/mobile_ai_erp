import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';

class PriceStockWidget extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final int discountPercentage;
  final ProductVariant? selectedVariant;

  const PriceStockWidget({
    super.key,
    required this.price,
    this.originalPrice,
    required this.discountPercentage,
    this.selectedVariant,
  });

  static final _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _currencyFormat.format(price),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (originalPrice != null) ...[
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  _currencyFormat.format(originalPrice),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                    decoration: TextDecoration.lineThrough,
                    decorationColor:
                        colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ],
            if (discountPercentage > 0) ...[
              const SizedBox(width: 10),
              _DiscountBadge(percentage: discountPercentage),
            ],
          ],
        ),
        if (selectedVariant != null) ...[
          const SizedBox(height: 8),
          _StockIndicator(variant: selectedVariant!),
        ],
      ],
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final int percentage;

  const _DiscountBadge({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '-$percentage%',
        style: TextStyle(
          color: Colors.red.shade700,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final ProductVariant variant;

  const _StockIndicator({required this.variant});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;
    final String text;

    if (!variant.inStock) {
      icon = Icons.cancel_outlined;
      color = Colors.red.shade600;
      text = 'Out of Stock';
    } else if (variant.isLowStock) {
      icon = Icons.warning_amber_rounded;
      color = Colors.orange.shade700;
      text = 'Only ${variant.stockQuantity} left in stock';
    } else {
      icon = Icons.check_circle_outline;
      color = Colors.green.shade600;
      text = 'In Stock';
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
