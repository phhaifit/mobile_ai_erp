import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_navigator.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_route_args.dart';
import 'package:mobile_ai_erp/presentation/customer_management/store/customer_store.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_empty_state.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CustomerAddressesScreen extends StatefulWidget {
  const CustomerAddressesScreen({super.key, required this.args});

  final CustomerAddressesArgs args;

  @override
  State<CustomerAddressesScreen> createState() =>
      _CustomerAddressesScreenState();
}

class _CustomerAddressesScreenState extends State<CustomerAddressesScreen> {
  final CustomerStore _store = getIt<CustomerStore>();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
        () => _store.loadAddresses(widget.args.customerId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (context) {
            final customer =
                _store.findCustomerById(widget.args.customerId);
            return Text(customer != null
                ? '${customer.firstName}\'s Addresses'
                : 'Addresses');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CustomerNavigator.openAddressForm(
          context,
          args: AddressFormArgs(customerId: widget.args.customerId),
        ),
        icon: const Icon(Icons.add_location_outlined),
        label: const Text('Add address'),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final addresses = _store.activeAddresses
              .where((a) => a.customerId == widget.args.customerId)
              .toList();

          if (addresses.isEmpty) {
            return const CustomerEmptyState(
              icon: Icons.location_off_outlined,
              title: 'No addresses yet',
              message: 'Add a shipping or billing address for this customer.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _AddressCard(
              address: addresses[index],
              onEdit: () => CustomerNavigator.openAddressForm(
                context,
                args: AddressFormArgs(
                  customerId: widget.args.customerId,
                  addressId: addresses[index].id,
                ),
              ),
              onSetDefault: addresses[index].isDefault
                  ? null
                  : () => _setDefault(addresses[index]),
              onDelete: () => _confirmDelete(addresses[index]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _setDefault(Address address) async {
    try {
      await _store.setDefaultAddress(
          widget.args.customerId, address.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('"${address.label}" set as default address.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t update default. Try again.')),
      );
    }
  }

  Future<void> _confirmDelete(Address address) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete address?'),
            content:
                Text('Delete "${address.label}"? This can\'t be undone.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    try {
      await _store.deleteAddress(address.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${address.label}".')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Couldn\'t delete address. Try again.')),
      );
    }
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    this.onSetDefault,
  });

  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.label,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                PopupMenuButton<_AddressAction>(
                  tooltip: 'Address actions',
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  onSelected: (action) {
                    switch (action) {
                      case _AddressAction.edit:
                        onEdit();
                        return;
                      case _AddressAction.setDefault:
                        onSetDefault?.call();
                        return;
                      case _AddressAction.delete:
                        onDelete();
                        return;
                    }
                  },
                  itemBuilder: (context) =>
                      <PopupMenuEntry<_AddressAction>>[
                    const PopupMenuItem<_AddressAction>(
                      value: _AddressAction.edit,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                      ),
                    ),
                    if (onSetDefault != null)
                      const PopupMenuItem<_AddressAction>(
                        value: _AddressAction.setDefault,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.star_outline),
                          title: Text('Set as default'),
                        ),
                      ),
                    const PopupMenuItem<_AddressAction>(
                      value: _AddressAction.delete,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_outline),
                        title: Text('Delete'),
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              address.displayAddress,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                CustomerStatusChip(label: address.type.label),
                if (address.isDefault)
                  const CustomerStatusChip(label: 'Default'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _AddressAction { edit, setDefault, delete }
