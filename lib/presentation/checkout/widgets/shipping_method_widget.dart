import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/shipping_method.dart';

/// Widget for displaying and selecting shipping methods
class ShippingMethodWidget extends StatelessWidget {
  const ShippingMethodWidget({
    super.key,
    required this.shippingMethods,
    required this.selectedMethod,
    required this.onMethodSelected,
    this.isLoading = false,
  });

  final List<ShippingMethod> shippingMethods;
  final ShippingMethod? selectedMethod;
  final ValueChanged<ShippingMethod> onMethodSelected;
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

    if (shippingMethods.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: shippingMethods
          .map((method) => _buildShippingMethodCard(context, method))
          .toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No shipping methods available',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your delivery address',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingMethodCard(BuildContext context, ShippingMethod method) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedMethod?.id == method.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: method.isAvailable ? () => onMethodSelected(method) : null,
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
                onChanged: method.isAvailable ? (_) => onMethodSelected(method) : null,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getShippingIcon(method.name),
                          size: 20,
                          color: method.isAvailable
                              ? colorScheme.primary
                              : colorScheme.outline,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            method.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: method.isAvailable
                                      ? null
                                      : colorScheme.outline,
                                ),
                          ),
                        ),
                        if (method.carrier != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              method.carrier!,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: method.isAvailable
                                ? null
                                : colorScheme.outline,
                          ),
                    ),
                    if (!method.isAvailable && method.unavailableReason != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        method.unavailableReason!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: method.isAvailable
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          method.estimatedDeliveryText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: method.isAvailable
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.outline,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          method.formattedCost,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: method.isAvailable
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                    if (method.trackingSupported || method.insuranceIncluded) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (method.trackingSupported)
                            _buildFeatureChip(context, 'Tracking', Icons.location_searching),
                          if (method.insuranceIncluded)
                            _buildFeatureChip(context, 'Insured', Icons.verified_user_outlined),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  IconData _getShippingIcon(String methodName) {
    final name = methodName.toLowerCase();
    if (name.contains('express') || name.contains('fast')) {
      return Icons.bolt_outlined;
    }
    if (name.contains('same day') || name.contains('today')) {
      return Icons.today_outlined;
    }
    if (name.contains('pickup') || name.contains('collect')) {
      return Icons.store_outlined;
    }
    if (name.contains('overnight') || name.contains('next day')) {
      return Icons.nightlight_outlined;
    }
    return Icons.local_shipping_outlined;
  }
}
