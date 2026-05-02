import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/price_formatter.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_calculation.dart';

class PriceSummaryCard extends StatelessWidget {
  final CartCalculationSummary summary;
  final AppliedCoupon? coupon;
  final String? discountLabel;
  final bool showDividers;
  final EdgeInsets? padding;

  const PriceSummaryCard({
    Key? key,
    required this.summary,
    this.coupon,
    this.discountLabel,
    this.showDividers = true,
    this.padding,
  }) : super(key: key);

  String _formatMoney(String value) {
    return PriceFormatter.formatPrice(double.tryParse(value) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = (int.tryParse(summary.discount) ?? 0) > 0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            _SummaryRow(
              label: 'Subtotal',
              amount: _formatMoney(summary.subtotal),
            ),

            if (hasDiscount) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                label: discountLabel ?? coupon?.name ?? 'Discount',
                amount: '-${_formatMoney(summary.discount)}',
                isDiscount: true,
              ),
            ],

            if (coupon != null) ...[
              const SizedBox(height: 8),
              _SummaryRow(label: 'Coupon', amount: coupon!.code, isMeta: true),
            ],

            if (showDividers) ...[
              const SizedBox(height: 12),
              Divider(color: Colors.grey[200]),
            ],
            const SizedBox(height: 12),

            _SummaryRow(
              label: 'Total',
              amount: _formatMoney(summary.total),
              isTotal: true,
            ),

            const SizedBox(height: 8),

            Text(
              '${summary.selectedItemsCount} selected item${summary.selectedItemsCount != 1 ? 's' : ''} • ${summary.selectedQuantity} qty',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),

            if (coupon != null &&
                coupon!.reason != null &&
                coupon!.reason!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                coupon!.reason!,
                style: TextStyle(
                  fontSize: 12,
                  color: coupon!.isValid ? Colors.grey[600] : Colors.red[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isDiscount;
  final bool isTotal;
  final bool isMeta;

  const _SummaryRow({
    required this.label,
    required this.amount,
    this.isDiscount = false,
    this.isTotal = false,
    this.isMeta = false,
  });

  @override
  Widget build(BuildContext context) {
    Color amountColor = Colors.black;
    if (isDiscount) amountColor = Colors.green[600]!;
    if (isTotal) amountColor = Colors.blue[600]!;
    if (isMeta) amountColor = Colors.grey[700]!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: Colors.grey[700],
          ),
        ),
        Flexible(
          child: Text(
            amount,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: amountColor,
            ),
          ),
        ),
      ],
    );
  }
}

class CompactPriceSummary extends StatelessWidget {
  final CartCalculationSummary summary;

  const CompactPriceSummary({Key? key, required this.summary})
    : super(key: key);

  String _formatMoney(String value) {
    return PriceFormatter.formatPrice(double.tryParse(value) ?? 0);
  }

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
                '${summary.selectedItemsCount} item${summary.selectedItemsCount != 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                'Total: ${_formatMoney(summary.total)}',
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
