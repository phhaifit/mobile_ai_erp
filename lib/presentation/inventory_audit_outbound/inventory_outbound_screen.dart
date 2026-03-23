import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_item.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_outbound_history_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_shared_widgets.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/store/inventory_audit_outbound_store.dart';

class InventoryOutboundScreen extends StatefulWidget {
  const InventoryOutboundScreen({super.key, this.store});

  final InventoryAuditOutboundStore? store;

  @override
  State<InventoryOutboundScreen> createState() => _InventoryOutboundScreenState();
}

class _InventoryOutboundScreenState extends State<InventoryOutboundScreen> {
  late final InventoryAuditOutboundStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? getIt<InventoryAuditOutboundStore>();
    _store.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outbound / Goods Issue')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 600;

          return Observer(
            builder: (_) {
              if (_store.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (isDesktop) {
                return Padding(
                  key: const Key('outbound_desktop_layout'),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: _OutboundForm(store: _store)),
                      const SizedBox(width: 12),
                      Expanded(flex: 1, child: _OutboundPreview(store: _store)),
                    ],
                  ),
                );
              }

              return ListView(
                key: const Key('outbound_mobile_layout'),
                padding: const EdgeInsets.all(16),
                children: [
                  _OutboundForm(store: _store),
                  const SizedBox(height: 12),
                  _OutboundPreview(store: _store),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _OutboundForm extends StatelessWidget {
  const _OutboundForm({required this.store});

  final InventoryAuditOutboundStore store;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final warehouseItems = store.warehouses
            .map(
              (warehouse) => DropdownMenuItem<String>(
                value: warehouse.id,
                child: Text('${warehouse.name} (${warehouse.location})'),
              ),
            )
            .toList(growable: false);

        final productItems = store.availableProductsForOutbound
            .map(
              (item) => DropdownMenuItem<String>(
                value: item.productId,
                child: Text('${item.productName} (${item.systemQty})'),
              ),
            )
            .toList(growable: false);

        final warehouseKey = store.outboundWarehouseId ?? 'none';

        return InventorySectionCard(
          title: 'Issue Goods',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WarehouseSelector(
                value: store.outboundWarehouseId,
                items: warehouseItems,
                onChanged: store.setOutboundWarehouse,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: Key('outbound_product_dropdown_$warehouseKey'),
                initialValue: store.outboundProductId,
                items: productItems,
                onChanged: store.setOutboundProduct,
                decoration: const InputDecoration(
                  labelText: 'Product',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                key: Key('outbound_qty_field_$warehouseKey'),
                initialValue: store.outboundQuantityInput,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                onChanged: store.setOutboundQuantity,
              ),
              const SizedBox(height: 10),
              TextFormField(
                key: Key('outbound_note_field_$warehouseKey'),
                initialValue: store.outboundNote,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: store.setOutboundNote,
              ),
              if (store.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(store.errorMessage, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('outbound_submit_button'),
                onPressed: store.isSubmittingOutbound || !store.canSubmitOutbound
                    ? null
                    : () async {
                        final success = await store.submitOutbound();
                        if (!context.mounted) {
                          return;
                        }
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Outbound issue saved locally.')),
                          );
                        }
                      },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Submit Outbound'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OutboundPreview extends StatelessWidget {
  const _OutboundPreview({required this.store});

  final InventoryAuditOutboundStore store;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final InventoryItem? selected = store.selectedOutboundItem;

        return InventorySectionCard(
          title: 'Stock Preview',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selected == null)
                const Text('Select warehouse and product to preview available stock.')
              else ...[
                Text('Product: ${selected.productName}'),
                Text('Available: ${selected.systemQty} ${selected.unit}'),
                Text('Warehouse: ${store.getWarehouseName(selected.warehouseId)}'),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent Outbound',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    key: const Key('open_outbound_history_button'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => InventoryOutboundHistoryScreen(store: store),
                        ),
                      );
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (store.outboundRecords.isEmpty)
                const Text('No outbound records yet.')
              else
                ...store.outboundRecords.take(5).map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${formatDateTime(record.createdAt)} - ${record.productName} x${record.quantity}',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

