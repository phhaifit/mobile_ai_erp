import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_line.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_item.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_audit_summary_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_outbound_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_shared_widgets.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/store/inventory_audit_outbound_store.dart';

class InventoryAuditScreen extends StatefulWidget {
  const InventoryAuditScreen({super.key, this.store});

  final InventoryAuditOutboundStore? store;

  @override
  State<InventoryAuditScreen> createState() => _InventoryAuditScreenState();
}

class _InventoryAuditScreenState extends State<InventoryAuditScreen> {
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
      appBar: AppBar(
        title: const Text('Inventory Audit'),
        actions: [
          IconButton(
            key: const Key('open_audit_summary_button'),
            tooltip: 'Audit Summary',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InventoryAuditSummaryScreen(store: _store),
                ),
              );
            },
            icon: const Icon(Icons.summarize_outlined),
          ),
          IconButton(
            key: const Key('open_outbound_button'),
            tooltip: 'Outbound',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => InventoryOutboundScreen(store: _store),
                ),
              );
            },
            icon: const Icon(Icons.local_shipping_outlined),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Observer(
            builder: (_) {
              if (_store.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final isDesktop = constraints.maxWidth >= 600;
              if (isDesktop) {
                return _AuditDesktopBody(store: _store);
              }
              return _AuditMobileBody(store: _store);
            },
          );
        },
      ),
    );
  }
}

class _AuditDesktopBody extends StatelessWidget {
  const _AuditDesktopBody({required this.store});

  final InventoryAuditOutboundStore store;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _AuditTopBar(store: store),
              const SizedBox(height: 12),
              if (store.errorMessage.isNotEmpty)
                Text(store.errorMessage, style: const TextStyle(color: Colors.red)),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: InventorySectionCard(
                        title: 'System Quantities',
                        child: _ProductSystemList(store: store, compact: false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: InventorySectionCard(
                        title: 'Physical Count & Discrepancy',
                        trailing: FilledButton(
                          key: const Key('audit_save_button_desktop'),
                          onPressed: store.isSubmitting || !store.canSaveAudit
                              ? null
                              : () async {
                                  final success = await store.saveAuditSession();
                                  if (!context.mounted) {
                                    return;
                                  }
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Audit session saved locally.')),
                                    );
                                  }
                                },
                          child: const Text('Save Audit'),
                        ),
                        child: _AuditDetailPanel(store: store),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AuditMobileBody extends StatelessWidget {
  const _AuditMobileBody({required this.store});

  final InventoryAuditOutboundStore store;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _AuditTopBar(store: store),
              const SizedBox(height: 12),
              if (store.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(store.errorMessage, style: const TextStyle(color: Colors.red)),
                ),
              InventorySectionCard(
                title: 'Audit Items',
                child: _ProductSystemList(store: store, compact: true),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('audit_save_button_mobile'),
                  onPressed: store.isSubmitting || !store.canSaveAudit
                      ? null
                      : () async {
                          final success = await store.saveAuditSession();
                          if (!context.mounted) {
                            return;
                          }
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Audit session saved locally.')),
                            );
                          }
                        },
                  child: const Text('Save Audit Session'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AuditTopBar extends StatelessWidget {
  const _AuditTopBar({required this.store});

  final InventoryAuditOutboundStore store;

  @override
  Widget build(BuildContext context) {
    final warehouseItems = store.warehouses
        .map(
          (warehouse) => DropdownMenuItem<String>(
            value: warehouse.id,
            child: Text('${warehouse.name} (${warehouse.location})'),
          ),
        )
        .toList(growable: false);

    return InventorySectionCard(
      title: 'Audit Session',
      child: Column(
        children: [
          WarehouseSelector(
            value: store.selectedWarehouseId,
            items: warehouseItems,
            onChanged: (value) {
              store.setSelectedWarehouse(value);
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Chip(label: Text('Items: ${store.inventoryItems.length}')),
              Chip(label: Text('Mismatch: ${store.mismatchCount}')),
              Chip(label: Text('Total Diff: ${store.totalAbsoluteDiscrepancy}')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductSystemList extends StatelessWidget {
  const _ProductSystemList({required this.store, required this.compact});

  final InventoryAuditOutboundStore store;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (store.inventoryItems.isEmpty) {
      return const Center(child: Text('No inventory found for selected warehouse.'));
    }

    return ListView.separated(
      key: Key(compact ? 'audit_mobile_list' : 'audit_desktop_list'),
      shrinkWrap: true,
      physics: compact ? const NeverScrollableScrollPhysics() : null,
      itemCount: store.inventoryItems.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final item = store.inventoryItems[index];
        final line = _lineForItem(store, item);

        return ListTile(
          onTap: compact ? null : () => store.setSelectedAuditProduct(item.productId),
          selected: !compact && item.productId == store.selectedAuditProductId,
          title: Text(item.productName),
          subtitle: Text('System: ${item.systemQty} ${item.unit}'),
          trailing: compact
              ? SizedBox(
                  width: 190,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          key: Key(
                            'mobile_input_${store.selectedWarehouseId ?? 'none'}_${item.productId}',
                          ),
                          initialValue: store.getPhysicalCountInput(item.productId),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Count'),
                          onChanged: (value) {
                            store.setPhysicalCount(item.productId, value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      DiscrepancyBadge(discrepancy: line.discrepancy),
                    ],
                  ),
                )
              : DiscrepancyBadge(discrepancy: line.discrepancy),
        );
      },
    );
  }

  AuditLine _lineForItem(InventoryAuditOutboundStore store, InventoryItem item) {
    for (final line in store.auditLines) {
      if (line.productId == item.productId) {
        return line;
      }
    }
    return AuditLine(
      productId: item.productId,
      productName: item.productName,
      systemQty: item.systemQty,
      physicalQty: item.systemQty,
      discrepancy: 0,
      unit: item.unit,
    );
  }
}

class _AuditDetailPanel extends StatelessWidget {
  const _AuditDetailPanel({required this.store});

  final InventoryAuditOutboundStore store;

  @override
  Widget build(BuildContext context) {
    final selectedItem = store.getSelectedAuditItem();
    if (selectedItem == null) {
      return const Text('Select a product from the left list to audit.');
    }

    final line = _lineForItem(selectedItem.productId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(selectedItem.productName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('System Quantity: ${selectedItem.systemQty} ${selectedItem.unit}'),
        const SizedBox(height: 8),
        TextFormField(
          key: Key(
            'desktop_input_${selectedItem.warehouseId}_${selectedItem.productId}',
          ),
          initialValue: store.getPhysicalCountInput(selectedItem.productId),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Physical Count',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            store.setPhysicalCount(selectedItem.productId, value);
          },
        ),
        const SizedBox(height: 10),
        DiscrepancyBadge(discrepancy: line.discrepancy),
      ],
    );
  }

  AuditLine _lineForItem(String productId) {
    for (final line in store.auditLines) {
      if (line.productId == productId) {
        return line;
      }
    }
    return const AuditLine(
      productId: '',
      productName: '',
      systemQty: 0,
      physicalQty: 0,
      discrepancy: 0,
    );
  }
}


