import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/payment_method.dart';

/// Widget for displaying and selecting payment methods
class PaymentMethodWidget extends StatelessWidget {
  const PaymentMethodWidget({
    super.key,
    required this.paymentMethods,
    required this.selectedMethod,
    required this.onMethodSelected,
    this.isLoading = false,
  });

  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? selectedMethod;
  final ValueChanged<PaymentMethod> onMethodSelected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (paymentMethods.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: paymentMethods
          .map((method) => _buildPaymentMethodCard(context, method))
          .toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(
            Icons.payment_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No payment methods available',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, PaymentMethod method) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedMethod?.id == method.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: method.isEnabled ? () => onMethodSelected(method) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : null,
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: method.isEnabled ? (_) => onMethodSelected(method) : null,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPaymentIcon(method.type),
                  size: 24,
                  color: method.isEnabled
                      ? colorScheme.primary
                      : colorScheme.outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: method.isEnabled
                                ? null
                                : colorScheme.outline,
                          ),
                    ),
                    if (method.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        method.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: method.isEnabled
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.outline,
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (method.fee > 0 || method.feePercentage > 0)
                          Text(
                            'Fee: ${method.feeDescription}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: method.isEnabled
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.outline,
                                ),
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

  IconData _getPaymentIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.cod:
        return Icons.money_outlined;
      case PaymentMethodType.bankTransfer:
        return Icons.account_balance_outlined;
      case PaymentMethodType.eWallet:
        return Icons.account_balance_wallet_outlined;
      case PaymentMethodType.creditCard:
        return Icons.credit_card_outlined;
      case PaymentMethodType.paymentGateway:
        return Icons.payment_outlined;
    }
  }
}
