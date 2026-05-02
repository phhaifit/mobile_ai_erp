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
        final canChooseProducts = store.transferSourceWarehouseId != null;

        return Card(
          child: SingleChildScrollView(
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
                const SizedBox(height: 8),
                const FlowIntroCard(
                  title: 'Move stock with fewer mistakes',
                  message:
                      'Choose the source first, then the destination and product. The preview updates with live available stock before you create the transfer.',
                ),
                const SizedBox(height: 16),
                FlowStepSection(
                  step: 1,
                  title: 'Choose the warehouse route',
                  subtitle:
                      'The destination list excludes the source warehouse automatically.',
                  child: Column(
                    children: [
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
                                    warehouse.id !=
                                    store.transferSourceWarehouseId,
                              )
                              .toList(growable: false),
                          onChanged: store.setTransferDestinationWarehouse,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FlowStepSection(
                  step: 2,
                  title: 'Choose a product',
                  subtitle: canChooseProducts
                      ? 'Only products with available stock in the source warehouse are shown.'
                      : 'Select a source warehouse first to unlock available products.',
                  child: ProductDropdown(
                    key: Key(
                      'transfer_product_${store.transferSourceWarehouseId ?? 'none'}_${store.transferProductId ?? 'none'}',
                    ),
                    label: isDesktop ? 'Product' : 'Step 2: Product',
                    value: store.transferProductId,
                    products: store.availableTransferProducts,
                    onChanged: store.setTransferProduct,
                  ),
                ),
                const SizedBox(height: 12),
                FlowStepSection(
                  step: 3,
                  title: 'Set the quantity',
                  subtitle:
                      'Stay within the available stock shown in the preview.',
                  child: TextFormField(
                    key: const Key('transfer_quantity_field'),
                    keyboardType: TextInputType.number,
                    initialValue: store.transferQuantityInput,
                    onChanged: store.setTransferQuantity,
                    decoration: const InputDecoration(
                      labelText: 'Step 3: Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (store.errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      store.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: store.isSubmitting || !store.canCreateTransferDraft
                      ? null
                      : () async {
                          final success = await store.createTransferDraft();
                          if (!context.mounted) {
                            return;
                          }
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Transfer draft created.'),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.playlist_add_check_circle_outlined),
                  label: const Text('Create Transfer'),
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
        final hasRoute = store.transferSourceWarehouseId != null &&
            store.transferDestinationWarehouseId != null;

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
                const SizedBox(height: 12),
                if (!hasRoute)
                  const EmptyStatePanel(
                    title: 'Choose a route first',
                    message:
                        'Start with the source and destination warehouses. The stock preview becomes useful once the route is clear.',
                    icon: Icons.alt_route,
                  )
                else if (selected == null)
                  const EmptyStatePanel(
                    title: 'Select a product to continue',
                    message:
                        'Pick one product from the source warehouse to see live available stock before creating the transfer.',
                    icon: Icons.inventory_2_outlined,
                  )
                else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer route',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'From: ${store.getWarehouseName(store.transferSourceWarehouseId)}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'To: ${store.getWarehouseName(store.transferDestinationWarehouseId)}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected.productName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Available now',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${selected.availableQuantity} ${selected.unit}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Source warehouse: ${store.getWarehouseName(selected.warehouseId)}',
                        ),
                      ],
                    ),
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
