import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/stock_operation.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/store/stock_operations_store.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/widgets/stock_operations_shared_widgets.dart';

class OperationHistoryPanel extends StatelessWidget {
  const OperationHistoryPanel({
    super.key,
    required this.store,
    required this.isDesktop,
  });

  final StockOperationsStore store;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: StockOperationHistoryFilter.values
                  .map(
                    (filter) => ChoiceChip(
                      key: Key('history_filter_$filter'),
                      label: Text(_filterLabel(filter)),
                      selected: store.historyFilter == filter,
                      onSelected: (_) => store.setHistoryFilter(filter),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: store.filteredOperations.isEmpty
                  ? EmptyStatePanel(
                      title: _emptyTitle(store),
                      message: _emptyMessage(store),
                      icon: Icons.history_toggle_off,
                    )
                  : (isDesktop
                        ? DesktopHistoryTable(
                            store: store,
                            operations: store.filteredOperations,
                          )
                        : MobileHistoryList(
                            store: store,
                            operations: store.filteredOperations,
                          )),
            ),
          ],
        );
      },
    );
  }

  String _filterLabel(StockOperationHistoryFilter filter) {
    switch (filter) {
      case StockOperationHistoryFilter.all:
        return 'All';
      case StockOperationHistoryFilter.transfer:
        return 'Transfer';
      case StockOperationHistoryFilter.damaged:
        return 'Damaged';
      case StockOperationHistoryFilter.expired:
        return 'Expired';
    }
  }

  String _emptyTitle(StockOperationsStore store) {
    switch (store.historyFilter) {
      case StockOperationHistoryFilter.all:
        return 'No stock operations yet';
      case StockOperationHistoryFilter.transfer:
        return 'No transfer activity yet';
      case StockOperationHistoryFilter.damaged:
        return 'No damaged stock records yet';
      case StockOperationHistoryFilter.expired:
        return 'No expired stock records yet';
    }
  }

  String _emptyMessage(StockOperationsStore store) {
    switch (store.historyFilter) {
      case StockOperationHistoryFilter.all:
        return 'Create a transfer or record damaged/expired goods to build the audit trail here.';
      case StockOperationHistoryFilter.transfer:
        return 'Transfers will appear here after you create and process them.';
      case StockOperationHistoryFilter.damaged:
        return 'Damaged stock adjustments will appear here once they are saved.';
      case StockOperationHistoryFilter.expired:
        return 'Expired stock adjustments will appear here once they are saved.';
    }
  }
}

class DesktopHistoryTable extends StatelessWidget {
  const DesktopHistoryTable({
    super.key,
    required this.store,
    required this.operations,
  });

  final StockOperationsStore store;
  final List<StockOperation> operations;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Product / Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Warehouses',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Action',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: operations.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final operation = operations[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(formatDateTime(operation.createdAt)),
                          ),
                          Expanded(
                            flex: 2,
                            child: OperationTypeBadge(type: operation.type),
                          ),
                          Expanded(
                            flex: 3,
                            child: _DesktopOperationSummary(
                              operation: operation,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: WarehouseRouteSummary(
                              operation: operation,
                              compact: true,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: OperationStatusBadge(
                              status: operation.status,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: _TransferActionButton(
                              store: store,
                              operation: operation,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _HistorySupportingDetails(operation: operation),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MobileHistoryList extends StatelessWidget {
  const MobileHistoryList({
    super.key,
    required this.store,
    required this.operations,
  });

  final StockOperationsStore store;
  final List<StockOperation> operations;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: false,
      physics: const ClampingScrollPhysics(),
      itemCount: operations.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final operation = operations[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: OperationTypeBadge(type: operation.type)),
                    const SizedBox(width: 8),
                    OperationStatusBadge(status: operation.status),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  operation.productName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SummaryChip(label: 'Qty', value: '${operation.quantity}'),
                    SummaryChip(
                      label: 'Time',
                      value: formatDateTime(operation.createdAt),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _HistorySupportingDetails(operation: operation),
                const SizedBox(height: 10),
                _TransferActionButton(store: store, operation: operation),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TransferActionButton extends StatelessWidget {
  const _TransferActionButton({required this.store, required this.operation});

  final StockOperationsStore store;
  final StockOperation operation;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (operation.type != StockOperationType.transfer) {
          return const SizedBox.shrink();
        }

        if (operation.status == StockOperationStatus.draft) {
          return TextButton(
            key: Key('approve_transfer_${operation.id}'),
            onPressed: store.isSubmitting
                ? null
                : () async {
                    final success = await store.approveSelectedTransfer(
                      operation.id,
                    );
                    if (!context.mounted || !success) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transfer approved.')),
                    );
                  },
            child: const Text('Approve'),
          );
        }

        if (operation.status == StockOperationStatus.approved) {
          return TextButton(
            key: Key('complete_transfer_${operation.id}'),
            onPressed: store.isSubmitting
                ? null
                : () async {
                    final success = await store.completeSelectedTransfer(
                      operation.id,
                    );
                    if (!context.mounted || !success) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transfer completed.')),
                    );
                  },
            child: const Text('Complete'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _AuditTrailSummary extends StatelessWidget {
  const _AuditTrailSummary({required this.operation});

  final StockOperation operation;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      Text(
        'Audit trail',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
    ];

    rows.addAll([
      _AuditTrailLine(
        label: 'Created by',
        value: operation.createdByName ?? operation.createdBy ?? '-',
      ),
      _AuditTrailLine(
        label: 'Created at',
        value: formatNullableDateTime(operation.createdAt),
      ),
    ]);

    if (operation.status == StockOperationStatus.approved ||
        operation.status == StockOperationStatus.completed) {
      rows.addAll([
        _AuditTrailLine(
          label: 'Approved by',
          value: operation.approvedByName ?? operation.approvedBy ?? '-',
        ),
        _AuditTrailLine(
          label: 'Approved at',
          value: formatNullableDateTime(operation.approvedAt),
        ),
      ]);
    }

    if (operation.status == StockOperationStatus.completed) {
      rows.addAll([
        _AuditTrailLine(
          label: 'Completed by',
          value: operation.completedByName ?? operation.completedBy ?? '-',
        ),
        _AuditTrailLine(
          label: 'Completed at',
          value: formatNullableDateTime(operation.completedAt),
        ),
      ]);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
    );
  }
}

class _HistorySupportingDetails extends StatelessWidget {
  const _HistorySupportingDetails({required this.operation});

  final StockOperation operation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WarehouseRouteSummary(operation: operation),
        const SizedBox(height: 10),
        _AuditTrailSummary(operation: operation),
        if ((operation.note ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Text(
              'Note: ${operation.note}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }
}

class _DesktopOperationSummary extends StatelessWidget {
  const _DesktopOperationSummary({required this.operation});

  final StockOperation operation;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      Text(
        operation.productName,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          SummaryChip(label: 'Qty', value: '${operation.quantity}'),
          SummaryChip(label: 'Time', value: formatDateTime(operation.createdAt)),
        ],
      ),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

class _AuditTrailLine extends StatelessWidget {
  const _AuditTrailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text('$label: $value', style: Theme.of(context).textTheme.bodySmall);
  }
}
