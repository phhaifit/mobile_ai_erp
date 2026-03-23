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
                  ? const Center(child: Text('No operations yet.'))
                  : (isDesktop
                        ? DesktopHistoryTable(
                            operations: store.filteredOperations,
                          )
                        : MobileHistoryList(
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
}

class DesktopHistoryTable extends StatelessWidget {
  const DesktopHistoryTable({super.key, required this.operations});

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
                    'Product',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Quantity',
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
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: operations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final operation = operations[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(formatDateTime(operation.createdAt)),
                      ),
                      Expanded(
                        flex: 2,
                        child: OperationTypeBadge(type: operation.type),
                      ),
                      Expanded(flex: 3, child: Text(operation.productName)),
                      Expanded(flex: 2, child: Text('${operation.quantity}')),
                      Expanded(
                        flex: 4,
                        child: Text(
                          '${operation.sourceWarehouseName ?? '-'} -> ${operation.destinationWarehouseName ?? '-'}',
                        ),
                      ),
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
  const MobileHistoryList({super.key, required this.operations});

  final List<StockOperation> operations;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: false,
      physics: const ClampingScrollPhysics(),
      itemCount: operations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final operation = operations[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OperationTypeBadge(type: operation.type),
                    Text(formatDateTime(operation.createdAt)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  operation.productName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text('Qty: ${operation.quantity}'),
                Text('From: ${operation.sourceWarehouseName ?? '-'}'),
                Text('To: ${operation.destinationWarehouseName ?? '-'}'),
                if ((operation.note ?? '').isNotEmpty)
                  Text('Note: ${operation.note}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
