import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Damaged / Expired Goods',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
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
                    products: store.getProductsByWarehouse(
                      store.disposalWarehouseId,
                    ),
                    onChanged: store.setDisposalProduct,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Damaged'),
                          selected:
                              store.disposalType == StockOperationType.damaged,
                          selectedColor: Colors.orange.shade200,
                          onSelected: (_) =>
                              store.setDisposalType(StockOperationType.damaged),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Expired'),
                          selected:
                              store.disposalType == StockOperationType.expired,
                          selectedColor: Colors.red.shade200,
                          onSelected: (_) =>
                              store.setDisposalType(StockOperationType.expired),
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
                                    'Damaged/expired record saved locally.',
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
