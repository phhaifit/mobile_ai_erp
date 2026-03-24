import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/delivery_address.dart';

/// Widget for displaying and selecting delivery addresses
class AddressSelectionWidget extends StatelessWidget {
  const AddressSelectionWidget({
    super.key,
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressSelected,
    this.onAddNewAddress,
    this.onEditAddress,
    this.isLoading = false,
  });

  final List<DeliveryAddress> addresses;
  final DeliveryAddress? selectedAddress;
  final ValueChanged<DeliveryAddress> onAddressSelected;
  final VoidCallback? onAddNewAddress;
  final void Function(DeliveryAddress)? onEditAddress;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (addresses.isEmpty)
          _buildEmptyState(context)
        else
          ...addresses.map((address) => _buildAddressCard(context, address)),
        if (onAddNewAddress != null) ...[
          const SizedBox(height: 12),
          _buildAddNewButton(context),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No saved addresses',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new delivery address to continue',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (onAddNewAddress != null) ...[
            const SizedBox(height: 16),
            _buildAddNewButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, DeliveryAddress address) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedAddress?.id == address.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onAddressSelected(address),
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
                onChanged: (_) => onAddressSelected(address),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (address.isDefault) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Default',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            address.fullName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.phone ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      address.formattedAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (onEditAddress != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  iconSize: 20,
                  onPressed: () => onEditAddress!(address),
                  tooltip: 'Edit address',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onAddNewAddress,
      icon: const Icon(Icons.add_location_outlined),
      label: const Text('Add New Address'),
    );
  }
}
