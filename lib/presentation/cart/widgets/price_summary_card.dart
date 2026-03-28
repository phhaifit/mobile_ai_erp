import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/price_formatter.dart';

/// Card widget displaying price breakdown summary
class PriceSummaryCard extends StatelessWidget {
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double shippingAmount;
  final double total;
  final String? discountLabel;
  final bool showDividers;
  final EdgeInsets? padding;
  final bool? isShippingDetermined;

  const PriceSummaryCard({
    Key? key,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.shippingAmount,
    required this.total,
    this.discountLabel,
    this.showDividers = true,
    this.padding,
    this.isShippingDetermined,
  }) : super(key: key);

  String _getShippingDisplayText() {
    if (shippingAmount == 0) {
      if (isShippingDetermined == false) {
        return 'Calculated at checkout';
      }
      return 'FREE';
    }
    return PriceFormatter.formatPrice(shippingAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Order Summary',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (showDividers) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey[200]),
            ],
            const SizedBox(height: 12),
            // Subtotal row
            _SummaryRow(
              label: 'Subtotal',
              amount: PriceFormatter.formatPrice(subtotal),
              isBold: false,
            ),
            const SizedBox(height: 8),
            // Discount row (if applicable)
            if (discountAmount > 0) ...[
              _SummaryRow(
                label: discountLabel ?? 'Discount',
                amount: '-${PriceFormatter.formatPrice(discountAmount)}',
                isBold: false,
                isDiscount: true,
              ),
              const SizedBox(height: 8),
            ],
            // Tax row
            _SummaryRow(
              label: 'Tax',
              amount: PriceFormatter.formatPrice(taxAmount),
              isBold: false,
            ),
            // Shipping row - only show when determined
            if (isShippingDetermined ?? true) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                label: 'Shipping',
                amount: _getShippingDisplayText(),
                isBold: false,
                isShipping: shippingAmount == 0,
              ),
            ],
            if (showDividers) ...[
              const SizedBox(height: 12),
              Divider(color: Colors.grey[200]),
            ],
            const SizedBox(height: 12),
            // Total row
            _SummaryRow(
              label: 'Total',
              amount: PriceFormatter.formatPrice(total),
              isBold: true,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual price summary row
class _SummaryRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isBold;
  final bool isDiscount;
  final bool isShipping;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.amount,
    this.isBold = false,
    this.isDiscount = false,
    this.isShipping = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    Color amountColor = Colors.black;
    if (isDiscount) amountColor = Colors.green[600]!;
    if (isShipping) amountColor = Colors.green[600]!;
    if (isTotal) amountColor = Colors.blue[600]!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal
                ? FontWeight.bold
                : (isBold ? FontWeight.w600 : FontWeight.w400),
            color: amountColor,
          ),
        ),
      ],
    );
  }
}

/// Compact price summary (for mini cart)
class CompactPriceSummary extends StatelessWidget {
  final double subtotal;
  final double total;
  final int itemCount;

  const CompactPriceSummary({
    Key? key,
    required this.subtotal,
    required this.total,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.grey[200]),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$itemCount item${itemCount != 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
