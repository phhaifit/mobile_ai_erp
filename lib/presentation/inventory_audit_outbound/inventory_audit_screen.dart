import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_line.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/inventory_item.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_audit_summary_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_outbound_screen.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_shared_widgets.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/models/inventory_workflow_view_models.dart';
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

  Future<void> _run(
    Future<bool> Function() command,
    String successMessage,
  ) async {
    final success = await command();
    if (!mounted) {
      return;
    }
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    }
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

              if (_store.warehouses.isEmpty) {
                return _EmptyState(
                  message: 'No warehouse found.',
                  onRetry: _store.loadInitialData,
                );
              }

              final isDesktop = constraints.maxWidth >= 600;
              if (isDesktop) {
                return _AuditDesktopBody(
                  store: _store,
                  onOpenSession: () => _run(_store.openSession, 'Session opened.'),
                  onSubmitCounts: () =>
                      _run(_store.submitCounts, 'Counts submitted.'),
                  onCloseSession: () => _run(_store.closeSession, 'Session closed.'),
                  onReconcile: () => _run(
                    _store.reconcileSession,
                    'Reconciled and stock adjusted.',
                  ),
                  onApprove: () => _run(_store.approveSession, 'Session approved.'),
                  onReject: () => _run(_store.rejectSession, 'Session rejected.'),
                );
              }
              return _AuditMobileBody(
                store: _store,
                onOpenSession: () => _run(_store.openSession, 'Session opened.'),
                onSubmitCounts: () => _run(_store.submitCounts, 'Counts submitted.'),
                onCloseSession: () => _run(_store.closeSession, 'Session closed.'),
                onReconcile: () => _run(
                  _store.reconcileSession,
                  'Reconciled and stock adjusted.',
                ),
                onApprove: () => _run(_store.approveSession, 'Session approved.'),
                onReject: () => _run(_store.rejectSession, 'Session rejected.'),
              );
            },
          );
        },
      ),
    );
  }
}

class _AuditDesktopBody extends StatelessWidget {
  const _AuditDesktopBody({
    required this.store,
    required this.onOpenSession,
    required this.onSubmitCounts,
    required this.onCloseSession,
    required this.onReconcile,
    required this.onApprove,
    required this.onReject,
  });

  final InventoryAuditOutboundStore store;
  final VoidCallback onOpenSession;
  final VoidCallback onSubmitCounts;
  final VoidCallback onCloseSession;
  final VoidCallback onReconcile;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _AuditTopBar(
                store: store,
                onOpenSession: onOpenSession,
                onSubmitCounts: onSubmitCounts,
                onCloseSession: onCloseSession,
                onReconcile: onReconcile,
                onApprove: onApprove,
                onReject: onReject,
              ),
              const SizedBox(height: 12),
              if (store.errorMessage.isNotEmpty)
                _ErrorBanner(message: store.errorMessage),
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
                        title: 'Count Line Detail',
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
  const _AuditMobileBody({
    required this.store,
    required this.onOpenSession,
    required this.onSubmitCounts,
    required this.onCloseSession,
    required this.onReconcile,
    required this.onApprove,
    required this.onReject,
  });

  final InventoryAuditOutboundStore store;
  final VoidCallback onOpenSession;
  final VoidCallback onSubmitCounts;
  final VoidCallback onCloseSession;
  final VoidCallback onReconcile;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return RefreshIndicator(
          onRefresh: store.loadInitialData,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AuditTopBar(
                store: store,
                onOpenSession: onOpenSession,
                onSubmitCounts: onSubmitCounts,
                onCloseSession: onCloseSession,
                onReconcile: onReconcile,
                onApprove: onApprove,
                onReject: onReject,
              ),
              const SizedBox(height: 12),
              if (store.errorMessage.isNotEmpty)
                _ErrorBanner(message: store.errorMessage),
              InventorySectionCard(
                title: 'Audit Items',
                child: _ProductSystemList(store: store, compact: true),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AuditTopBar extends StatelessWidget {
  const _AuditTopBar({
    required this.store,
    required this.onOpenSession,
    required this.onSubmitCounts,
    required this.onCloseSession,
    required this.onReconcile,
    required this.onApprove,
    required this.onReject,
  });

  final InventoryAuditOutboundStore store;
  final VoidCallback onOpenSession;
  final VoidCallback onSubmitCounts;
  final VoidCallback onCloseSession;
  final VoidCallback onReconcile;
  final VoidCallback onApprove;
  final VoidCallback onReject;

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

    final session = store.activeSession;

    return InventorySectionCard(
      title: 'Stocktake Session',
      trailing: session == null
          ? const Text('No active session')
          : WorkflowStatusBadge.stocktake(status: session.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WarehouseSelector(
            value: store.selectedWarehouseId,
            items: warehouseItems,
            onChanged: (value) {
              store.setSelectedWarehouse(value);
            },
          ),
          const SizedBox(height: 10),
          if (session != null)
            Text('Session: ${session.code} | Opened: ${formatDateTime(session.openedAt)}'),
          const SizedBox(height: 10),
          WorkflowStepper(
            steps: const ['Open', 'Count', 'Submit', 'Close', 'Reconcile', 'Approve'],
            currentIndex: _stepIndex(session?.status),
          ),
          const SizedBox(height: 10),
          WorkflowActionBar(
            actions: [
              ActionGateItem(
                key: const Key('audit_open_session_button'),
                label: 'Open Session',
                onPressed: onOpenSession,
                enabled: store.canOpenSession,
                disabledReason: store.openSessionDisabledReason,
              ),
              ActionGateItem(
                key: const Key('audit_submit_counts_button'),
                label: 'Submit Counts',
                onPressed: onSubmitCounts,
                enabled: store.canSubmitCounts,
                disabledReason: store.submitCountsDisabledReason,
              ),
              ActionGateItem(
                key: const Key('audit_close_session_button'),
                label: 'Close Session',
                onPressed: onCloseSession,
                enabled: store.canCloseSession,
                disabledReason: store.closeSessionDisabledReason,
              ),
              ActionGateItem(
                key: const Key('audit_reconcile_button'),
                label: 'Reconcile',
                onPressed: onReconcile,
                enabled: store.canReconcileSession,
                disabledReason: store.reconcileSessionDisabledReason,
              ),
              ActionGateItem(
                key: const Key('audit_approve_button'),
                label: 'Approve',
                onPressed: onApprove,
                enabled: store.canApproveSession,
                disabledReason: store.approveSessionDisabledReason,
              ),
              ActionGateItem(
                key: const Key('audit_reject_button'),
                label: 'Reject',
                onPressed: onReject,
                enabled: store.canRejectSession,
                disabledReason: store.approveSessionDisabledReason,
              ),
            ],
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

  int _stepIndex(StocktakeSessionStatus? status) {
    switch (status) {
      case StocktakeSessionStatus.counting:
        return 1;
      case StocktakeSessionStatus.submitted:
        return 3;
      case StocktakeSessionStatus.reconciled:
        return 4;
      case StocktakeSessionStatus.approved:
      case StocktakeSessionStatus.rejected:
        return 5;
      case StocktakeSessionStatus.draft:
      case null:
        return 0;
    }
  }
}

class _ProductSystemList extends StatelessWidget {
  const _ProductSystemList({required this.store, required this.compact});

  final InventoryAuditOutboundStore store;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (store.inventoryItems.isEmpty) {
          return _EmptyState(
            message: 'No inventory found for selected warehouse.',
            onRetry: store.loadInitialData,
          );
        }

        return KeyedSubtree(
          key: Key(compact ? 'audit_mobile_list' : 'audit_desktop_list'),
          child: ListView.separated(
            key: Key(
              '${compact ? 'audit_mobile_list_view' : 'audit_desktop_list_view'}_${store.selectedWarehouseId ?? 'none'}',
            ),
            shrinkWrap: true,
            physics: compact ? const NeverScrollableScrollPhysics() : null,
            itemCount: store.inventoryItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final item = store.inventoryItems[index];
              final line = _lineForItem(store, item);

              return ListTile(
                key: Key('audit_item_${item.warehouseId}_${item.productId}'),
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
          ),
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
      return const Text('Select a product from the left list to count.');
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
          key: Key('desktop_input_${selectedItem.warehouseId}_${selectedItem.productId}'),
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
