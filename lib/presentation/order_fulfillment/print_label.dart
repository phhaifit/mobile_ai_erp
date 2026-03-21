import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/package_info.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';

class PrintLabelScreen extends StatefulWidget {
  @override
  State<PrintLabelScreen> createState() => _PrintLabelScreenState();
}

class _PrintLabelScreenState extends State<PrintLabelScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();
  int _selectedPackageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final order = _store.selectedOrder;
        return Scaffold(
          appBar: AppBar(
            title: Text(
                order != null ? 'Labels ${order.id}' : 'Print Label'),
          ),
          body: order == null
              ? const Center(child: Text('No order selected'))
              : order.packages.isEmpty
                  ? _buildNoPackages()
                  : _buildBody(order.packages),
        );
      },
    );
  }

  Widget _buildNoPackages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.print_disabled,
              size: 64, color: Theme.of(context).hintColor),
          const SizedBox(height: 16),
          Text(
            'No packages to print labels for',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Create packages first in the Packaging screen',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<PackageInfo> packages) {
    final order = _store.selectedOrder!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (packages.length > 1) _buildPackageSelector(packages),
          const SizedBox(height: 16),
          _buildLabelPreview(order, packages[_selectedPackageIndex]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Print functionality will be available '
                        'with API integration in Phase 2'),
                  ),
                );
              },
              icon: const Icon(Icons.print),
              label: const Text('Print Label'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSelector(List<PackageInfo> packages) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedPackageIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(packages[index].label),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedPackageIndex = index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabelPreview(dynamic order, PackageInfo pkg) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Text(
              'SHIPPING LABEL',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender
                _buildLabelSection(
                  'FROM',
                  'Mobile AI ERP Warehouse',
                  '100 Nguyen Van Linh, District 7\nHo Chi Minh City, Vietnam',
                  'Tel: 028-1234-5678',
                ),
                const Divider(height: 24, thickness: 1),
                // Receiver
                _buildLabelSection(
                  'TO',
                  order.customerName,
                  order.shippingAddress,
                  'Tel: ${order.customerPhone}',
                ),
                const Divider(height: 24, thickness: 1),
                // Tracking & Package info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabelField(
                              'ORDER', order.id),
                          const SizedBox(height: 8),
                          _buildLabelField('PACKAGE', pkg.label),
                          const SizedBox(height: 8),
                          _buildLabelField(
                              'WEIGHT',
                              pkg.weight != null
                                  ? '${pkg.weight} kg'
                                  : 'N/A'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabelField('CHANNEL', order.channel),
                          const SizedBox(height: 8),
                          _buildLabelField('DIMENSIONS', pkg.dimensionsDisplay),
                          const SizedBox(height: 8),
                          _buildLabelField(
                              'ITEMS', '${pkg.items.length} product(s)'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (pkg.trackingNumber != null) ...[
                  const Divider(height: 24, thickness: 1),
                  // Barcode placeholder
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 220,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  30,
                                  (i) => Container(
                                    width: i % 3 == 0 ? 3 : 2,
                                    height: 30,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 0.5),
                                    color: i % 2 == 0
                                        ? Colors.black
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pkg.trackingNumber!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelSection(
      String title, String name, String address, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2),
        Text(address, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(phone, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildLabelField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
