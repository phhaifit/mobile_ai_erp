import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/product_stock.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/stock_operation.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/store/stock_operations_store.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/widgets/stock_operations_shared_widgets.dart';

class DamagedExpiredPanel extends StatelessWidget {
  const DamagedExpiredPanel({super.key, required this.store});

  final StockOperationsStore store;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final selectedProducts = store.getProductsByWarehouse(
          store.disposalWarehouseId,
        );
        ProductStock? selectedStock;
        for (final stock in selectedProducts) {
          if (stock.productId == store.disposalProductId) {
            selectedStock = stock;
            break;
          }
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Damaged / Expired Goods',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const FlowIntroCard(
                    title: 'Record stock loss clearly',
                    message:
                        'Choose the warehouse, confirm the affected product, then classify the issue as damaged or expired before saving the operation.',
                  ),
                  const SizedBox(height: 16),
                  FlowStepSection(
                    step: 1,
                    title: 'Pick the warehouse and product',
                    subtitle:
                        'Only products with available stock in the selected warehouse are shown.',
                    child: Column(
                      children: [
                        WarehouseDropdown(
                          label: 'Warehouse',
                          value: store.disposalWarehouseId,
                          warehouses: store.warehouses.toList(growable: false),
                          onChanged: store.setDisposalWarehouse,
                        ),
                        const SizedBox(height: 12),
                        ProductDropdown(
                          label: 'Product',
                          value: store.disposalProductId,
                          products: selectedProducts,
                          onChanged: store.setDisposalProduct,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FlowStepSection(
                    step: 2,
                    title: 'Classify the issue and quantity',
                    subtitle:
                        'Use a short note when the adjustment needs extra context.',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Damaged'),
                                selected:
                                    store.disposalType ==
                                    StockOperationType.damaged,
                                selectedColor: Colors.orange.shade200,
                                onSelected: (_) => store.setDisposalType(
                                  StockOperationType.damaged,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Expired'),
                                selected:
                                    store.disposalType ==
                                    StockOperationType.expired,
                                selectedColor: Colors.red.shade200,
                                onSelected: (_) => store.setDisposalType(
                                  StockOperationType.expired,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          initialValue: store.disposalQuantityInput,
                          onChanged: store.setDisposalQuantity,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: store.disposalNote,
                          onChanged: store.setDisposalNote,
                          decoration: const InputDecoration(
                            labelText: 'Note (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (selectedStock == null)
                    const EmptyStatePanel(
                      title: 'Choose an item to preview',
                      message:
                          'Select the warehouse and product to confirm available stock before recording the loss.',
                      icon: Icons.remove_shopping_cart_outlined,
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer
                            .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedStock.productName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Available now: ${selectedStock.availableQuantity} ${selectedStock.unit}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Warehouse: ${store.getWarehouseName(selectedStock.warehouseId)}',
                          ),
                        ],
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
                    onPressed:
                        store.isSubmitting || !store.canSubmitDamagedOrExpired
                        ? null
                        : () async {
                            final success = await store
                                .submitDamagedOrExpired();
                            if (!context.mounted) {
                              return;
                            }
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Damaged/expired record saved.',
                                  ),
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Operation'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
