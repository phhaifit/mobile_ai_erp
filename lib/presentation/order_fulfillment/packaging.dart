import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_item.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/package_info.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/package_item.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';

class PackagingScreen extends StatefulWidget {
  @override
  State<PackagingScreen> createState() => _PackagingScreenState();
}

class _PackagingScreenState extends State<PackagingScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final order = _store.selectedOrder;
        return Scaffold(
          appBar: AppBar(
            title:
                Text(order != null ? 'Packaging ${order.id}' : 'Packaging'),
          ),
          floatingActionButton: order != null
              ? FloatingActionButton.extended(
                  onPressed: () => _showCreatePackageDialog(order.items),
                  icon: const Icon(Icons.add),
                  label: const Text('New Package'),
                )
              : null,
          body: order == null
              ? const Center(child: Text('No order selected'))
              : _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    final order = _store.selectedOrder!;
    final packages = order.packages;

    if (packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Theme.of(context).hintColor),
            const SizedBox(height: 16),
            Text(
              'No packages yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a package to assign items',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      itemBuilder: (context, index) => _buildPackageCard(packages[index]),
    );
  }

  Widget _buildPackageCard(PackageInfo pkg) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      pkg.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                if (pkg.trackingNumber != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pkg.trackingNumber!,
                      style: const TextStyle(
                        color: Colors.teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (pkg.weight != null)
                  _buildMetric(Icons.scale, '${pkg.weight} kg'),
                if (pkg.weight != null) const SizedBox(width: 16),
                _buildMetric(Icons.straighten, pkg.dimensionsDisplay),
              ],
            ),
            if (pkg.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                'Items (${pkg.items.length})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...pkg.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.circle,
                            size: 6, color: Theme.of(context).hintColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          'x${item.quantity}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).hintColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  void _showCreatePackageDialog(List<FulfillmentItem> orderItems) {
    final labelController = TextEditingController();
    final weightController = TextEditingController();
    final lengthController = TextEditingController();
    final widthController = TextEditingController();
    final heightController = TextEditingController();
    final trackingController = TextEditingController();
    final selectedItems = <String, int>{};

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Create Package'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration:
                          const InputDecoration(labelText: 'Package Label'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: trackingController,
                      decoration: const InputDecoration(
                          labelText: 'Tracking Number (optional)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: weightController,
                      decoration:
                          const InputDecoration(labelText: 'Weight (kg)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lengthController,
                            decoration:
                                const InputDecoration(labelText: 'L (cm)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: widthController,
                            decoration:
                                const InputDecoration(labelText: 'W (cm)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            decoration:
                                const InputDecoration(labelText: 'H (cm)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Assign Items',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...orderItems.map((item) {
                      final maxQty = item.quantity - item.packedQuantity;
                      if (maxQty <= 0) return const SizedBox.shrink();
                      final currentQty = selectedItems[item.id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Available: $maxQty',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context).hintColor,
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 20),
                              onPressed: currentQty > 0
                                  ? () {
                                      setDialogState(() {
                                        selectedItems[item.id] =
                                            currentQty - 1;
                                      });
                                    }
                                  : null,
                            ),
                            Text('$currentQty'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  size: 20),
                              onPressed: currentQty < maxQty
                                  ? () {
                                      setDialogState(() {
                                        selectedItems[item.id] =
                                            currentQty + 1;
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (labelController.text.isEmpty) return;
                    final pkgItems = <PackageItem>[];
                    for (final entry in selectedItems.entries) {
                      if (entry.value > 0) {
                        final item =
                            orderItems.firstWhere((i) => i.id == entry.key);
                        pkgItems.add(PackageItem(
                          itemId: item.id,
                          productName: item.productName,
                          quantity: entry.value,
                        ));
                      }
                    }
                    final pkg = PackageInfo(
                      id: 'PKG-${DateTime.now().millisecondsSinceEpoch}',
                      orderId: _store.selectedOrder!.id,
                      label: labelController.text,
                      weight: double.tryParse(weightController.text),
                      length: double.tryParse(lengthController.text),
                      width: double.tryParse(widthController.text),
                      height: double.tryParse(heightController.text),
                      trackingNumber: trackingController.text.isNotEmpty
                          ? trackingController.text
                          : null,
                      items: pkgItems,
                    );
                    _store.addPackage(_store.selectedOrder!.id, pkg);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
