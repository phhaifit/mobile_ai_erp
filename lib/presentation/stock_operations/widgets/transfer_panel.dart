import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/store/stock_operations_store.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/widgets/stock_operations_shared_widgets.dart';

class TransferPanel extends StatelessWidget {
  const TransferPanel({
    super.key,
    required this.store,
    required this.isDesktop,
  });

  final StockOperationsStore store;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: TransferForm(store: store, isDesktop: true)),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: TransferPreview(store: store)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TransferForm(store: store, isDesktop: false),
                const SizedBox(height: 16),
                TransferPreview(store: store),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TransferForm extends StatelessWidget {
  const TransferForm({super.key, required this.store, required this.isDesktop});

  final StockOperationsStore store;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDesktop
                      ? 'Internal Stock Transfer'
                      : 'Step 1: Transfer Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: const Key('transfer_source_dropdown'),
                  child: WarehouseDropdown(
                    key: Key(
                      'transfer_source_${store.transferSourceWarehouseId ?? 'none'}',
                    ),
                    label: 'Source Warehouse',
                    value: store.transferSourceWarehouseId,
                    warehouses: store.warehouses.toList(growable: false),
                    onChanged: store.setTransferSourceWarehouse,
                  ),
                ),
                const SizedBox(height: 12),
                KeyedSubtree(
                  key: const Key('transfer_destination_dropdown'),
                  child: WarehouseDropdown(
                    key: Key(
                      'transfer_destination_${store.transferSourceWarehouseId ?? 'none'}_${store.transferDestinationWarehouseId ?? 'none'}',
                    ),
                    label: 'Destination Warehouse',
                    value: store.transferDestinationWarehouseId,
                    warehouses: store.warehouses
                        .where(
                          (warehouse) =>
                              warehouse.id != store.transferSourceWarehouseId,
                        )
                        .toList(growable: false),
                    onChanged: store.setTransferDestinationWarehouse,
                  ),
                ),
                const SizedBox(height: 12),
                ProductDropdown(
                  key: Key(
                    'transfer_product_${store.transferSourceWarehouseId ?? 'none'}_${store.transferProductId ?? 'none'}',
                  ),
                  label: isDesktop ? 'Product' : 'Step 2: Product',
                  value: store.transferProductId,
                  products: store.availableTransferProducts,
                  onChanged: store.setTransferProduct,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('transfer_quantity_field'),
                  keyboardType: TextInputType.number,
                  initialValue: store.transferQuantityInput,
                  onChanged: store.setTransferQuantity,
                  decoration: const InputDecoration(
                    labelText: 'Step 3: Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (store.errorMessage.isNotEmpty)
                  Text(
                    store.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: store.isSubmitting || !store.canSubmitTransfer
                      ? null
                      : () async {
                          final success = await store.submitTransfer();
                          if (!context.mounted) {
                            return;
                          }
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transfer submitted locally.'),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Submit Transfer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TransferPreview extends StatelessWidget {
  const TransferPreview({super.key, required this.store});

  final StockOperationsStore store;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final selected = store.selectedTransferStock;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock Preview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (selected == null)
                  const Text(
                    'Select source warehouse and product to view available stock.',
                  )
                else ...[
                  Text('Product: ${selected.productName}'),
                  Text(
                    'Warehouse: ${store.getWarehouseName(selected.warehouseId)}',
                  ),
                  Text(
                    'Available: ${selected.availableQuantity} ${selected.unit}',
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
