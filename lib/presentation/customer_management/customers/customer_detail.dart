import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_navigator.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_route_args.dart';
import 'package:mobile_ai_erp/presentation/customer_management/store/customer_store.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_detail_section_card.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.args});

  final CustomerDetailArgs args;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final CustomerStore _store = getIt<CustomerStore>();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => _store.loadCustomers());
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final customer = _store.findCustomerById(widget.args.customerId);
        if (customer == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Customer detail')),
            body: const Center(child: Text('Customer not found.')),
          );
        }

        final group = _store.findGroupById(customer.groupId);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Customer detail'),
            actions: <Widget>[
              IconButton(
                onPressed: () => CustomerNavigator.openCustomerForm(
                  context,
                  args: CustomerFormArgs(customerId: customer.id),
                ),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit customer',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _CustomerHeaderCard(customer: customer),
              const SizedBox(height: 16),
              CustomerDetailSectionCard(
                title: 'Profile',
                children: <Widget>[
                  CustomerDetailRow(label: 'Email', value: customer.email),
                  CustomerDetailRow(
                    label: 'Phone',
                    value: customer.phone ?? 'Not set',
                  ),
                  CustomerDetailRow(label: 'Type', value: customer.type.label),
                  CustomerDetailRow(
                    label: 'Group',
                    value: group?.name ?? 'No group',
                  ),
                  CustomerDetailRow(
                    label: 'Member since',
                    value: DateFormat('MMM d, y').format(customer.createdAt),
                  ),
                ],
              ),
              if (customer.notes != null && customer.notes!.trim().isNotEmpty)
                CustomerDetailSectionCard(
                  title: 'Notes',
                  children: <Widget>[
                    Text(
                      customer.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              CustomerDetailSectionCard(
                title: 'Addresses',
                trailing: TextButton.icon(
                  onPressed: () => CustomerNavigator.openAddresses(
                    context,
                    args: CustomerAddressesArgs(customerId: customer.id),
                  ),
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: const Text('Manage'),
                ),
                children: <Widget>[
                  _AddressPreview(store: _store, customerId: customer.id),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomerHeaderCard extends StatelessWidget {
  const _CustomerHeaderCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 30,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                customer.initials,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    customer.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      CustomerStatusChip(label: customer.status.label),
                      CustomerStatusChip(label: customer.type.label),
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

class _AddressPreview extends StatefulWidget {
  const _AddressPreview({required this.store, required this.customerId});

  final CustomerStore store;
  final String customerId;

  @override
  State<_AddressPreview> createState() => _AddressPreviewState();
}

class _AddressPreviewState extends State<_AddressPreview> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      try {
        await widget.store.loadAddresses(widget.customerId);
      } finally {
        if (mounted) setState(() => _loaded = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Observer(
      builder: (context) {
        final addresses = widget.store.activeAddresses.toList();

        if (addresses.isEmpty) {
          return const Text('No addresses added yet.');
        }

        final defaults = addresses.where((a) => a.isDefault).toList();
        final preview = defaults.isNotEmpty ? defaults.first : addresses.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              preview.label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              preview.displayAddress,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (addresses.length > 1) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                '+${addresses.length - 1} more address${addresses.length - 1 > 1 ? 'es' : ''}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
