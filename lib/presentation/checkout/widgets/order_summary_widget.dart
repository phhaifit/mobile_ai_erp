import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_item.dart';

/// Widget for displaying order summary with items and totals
class OrderSummaryWidget extends StatelessWidget {
  const OrderSummaryWidget({
    super.key,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.paymentFee,
    required this.discount,
    required this.grandTotal,
    this.couponCode,
    this.onRemoveCoupon,
    this.isEditable = false,
    this.onEditItems,
  });

  final List<CheckoutItem> items;
  final double subtotal;
  final double shippingCost;
  final double paymentFee;
  final double discount;
  final double grandTotal;
  final String? couponCode;
  final VoidCallback? onRemoveCoupon;
  final bool isEditable;
  final VoidCallback? onEditItems;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Items list
        ...items.map((item) => _buildItemCard(context, item)),

        if (isEditable && onEditItems != null) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: onEditItems,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Items'),
            ),
          ),
        ],

        const Divider(height: 32),

        // Price breakdown
        _buildPriceRow(context, 'Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        if (shippingCost > 0)
          _buildPriceRow(context, 'Shipping', '\$${shippingCost.toStringAsFixed(2)}'),
        if (paymentFee > 0)
          _buildPriceRow(
            context,
            'Payment Fee',
            '\$${paymentFee.toStringAsFixed(2)}',
          ),
        if (discount > 0) ...[
          _buildPriceRow(
            context,
            'Discount${couponCode != null ? ' ($couponCode)' : ''}',
            '-\$${discount.toStringAsFixed(2)}',
            isDiscount: true,
            trailing: onRemoveCoupon != null
                ? IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onRemoveCoupon,
                    tooltip: 'Remove coupon',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,
          ),
        ],

        const Divider(height: 24),

        // Grand total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '\$${grandTotal.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemCard(BuildContext context, CheckoutItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'x${item.quantity}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (item.variantString.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.variantString,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)} each',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    bool isDiscount = false,
    Widget? trailing,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (trailing != null) ...[
            const SizedBox(width: 4),
            trailing,
          ],
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDiscount ? colorScheme.primary : null,
                  fontWeight: isDiscount ? FontWeight.w600 : null,
                ),
          ),
        ],
      ),
    );
  }
}
