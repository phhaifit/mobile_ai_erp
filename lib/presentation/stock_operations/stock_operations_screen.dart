import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/product_stock.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/stock_operation.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/warehouse.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/store/stock_operations_store.dart';

class StockOperationsScreen extends StatefulWidget {
  const StockOperationsScreen({super.key, this.store});

  final StockOperationsStore? store;

  @override
  State<StockOperationsScreen> createState() => _StockOperationsScreenState();
}

class _StockOperationsScreenState extends State<StockOperationsScreen> {
  late final StockOperationsStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? getIt<StockOperationsStore>();
    _store.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;
        if (isDesktop) {
          return _buildDesktopShell(context);
        }
        return _buildMobileDashboard(context);
      },
    );
  }

  Widget _buildDesktopShell(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Operations')),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Row(
            children: [
              NavigationRail(
                selectedIndex: _indexOfView(_store.currentView),
                onDestinationSelected: (index) {
                  _store.setCurrentView(_viewByIndex(index));
                },
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.swap_horiz_outlined),
                    selectedIcon: Icon(Icons.swap_horiz),
                    label: Text('Transfer'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.report_problem_outlined),
                    selectedIcon: Icon(Icons.report_problem),
                    label: Text('Damaged/Expired'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history_outlined),
                    selectedIcon: Icon(Icons.history),
                    label: Text('History'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _desktopPanelByView(_store.currentView),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileDashboard(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Operations')),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DashboardSummary(store: _store),
                const SizedBox(height: 16),
                ..._store.dashboardActions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MobileActionTile(
                      title: _mobileTitleForAction(action),
                      subtitle: _mobileSubtitleForAction(action),
                      icon: action.icon,
                      onTap: () => _openMobileDetail(
                        context,
                        title: _mobileTitleForAction(action),
                        child: _mobileChildForAction(action),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _desktopPanelByView(StockOperationsView view) {
    switch (view) {
      case StockOperationsView.dashboard:
        return _StockDashboardPanel(
          store: _store,
          onNavigate: _store.setCurrentView,
        );
      case StockOperationsView.transfer:
        return _TransferPanel(store: _store, isDesktop: true);
      case StockOperationsView.damagedGoods:
        return _DamagedExpiredPanel(store: _store);
      case StockOperationsView.history:
        return _OperationHistoryPanel(store: _store, isDesktop: true);
    }
  }

  Future<void> _openMobileDetail(
    BuildContext context, {
    required String title,
    required Widget child,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  StockOperationsView _viewByIndex(int index) {
    switch (index) {
      case 0:
        return StockOperationsView.dashboard;
      case 1:
        return StockOperationsView.transfer;
      case 2:
        return StockOperationsView.damagedGoods;
      case 3:
      default:
        return StockOperationsView.history;
    }
  }

  int _indexOfView(StockOperationsView view) {
    switch (view) {
      case StockOperationsView.dashboard:
        return 0;
      case StockOperationsView.transfer:
        return 1;
      case StockOperationsView.damagedGoods:
        return 2;
      case StockOperationsView.history:
        return 3;
    }
  }
}

class _StockDashboardPanel extends StatelessWidget {
  const _StockDashboardPanel({required this.store, required this.onNavigate});

  final StockOperationsStore store;
  final ValueChanged<StockOperationsView> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stock Operations Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        _DashboardSummary(store: store),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: store.dashboardActions
                .map(
                  (action) => _DashboardActionCard(
                    title: action.title,
                    subtitle: action.subtitle,
                    icon: action.icon,
                    onTap: () => onNavigate(action.view),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _DashboardSummary extends StatelessWidget {
  const _DashboardSummary({required this.store});

  final StockOperationsStore store;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryChip(
              label: 'Total Operations',
              value: '${store.totalOperationsCount}',
            ),
            _SummaryChip(
              label: 'Damaged',
              value: '${store.damagedOperationsCount}',
            ),
            _SummaryChip(
              label: 'Expired',
              value: '${store.expiredOperationsCount}',
            ),
          ],
        );
      },
    );
  }
}

class _TransferPanel extends StatelessWidget {
  const _TransferPanel({required this.store, required this.isDesktop});

  final StockOperationsStore store;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _TransferForm(store: store, isDesktop: true),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: _TransferPreview(store: store)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TransferForm(store: store, isDesktop: false),
        const SizedBox(height: 16),
        _TransferPreview(store: store),
      ],
    );
  }
}

class _TransferForm extends StatelessWidget {
  const _TransferForm({required this.store, required this.isDesktop});

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
                  child: _WarehouseDropdown(
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
                  child: _WarehouseDropdown(
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
                _ProductDropdown(
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

class _TransferPreview extends StatelessWidget {
  const _TransferPreview({required this.store});

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
                  Text('Available: ${selected.availableQuantity} ${selected.unit}'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DamagedExpiredPanel extends StatelessWidget {
  const _DamagedExpiredPanel({required this.store});

  final StockOperationsStore store;

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
                const Text(
                  'Damaged / Expired Goods',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _WarehouseDropdown(
                  label: 'Warehouse',
                  value: store.disposalWarehouseId,
                  warehouses: store.warehouses.toList(growable: false),
                  onChanged: store.setDisposalWarehouse,
                ),
                const SizedBox(height: 12),
                _ProductDropdown(
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
                          final success = await store.submitDamagedOrExpired();
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
        );
      },
    );
  }
}

class _OperationHistoryPanel extends StatelessWidget {
  const _OperationHistoryPanel({required this.store, required this.isDesktop});

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
                        ? _DesktopHistoryTable(operations: store.filteredOperations)
                        : _MobileHistoryList(operations: store.filteredOperations)),
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

class _DesktopHistoryTable extends StatelessWidget {
  const _DesktopHistoryTable({required this.operations});

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
                        child: Text(_formatDateTime(operation.createdAt)),
                      ),
                      Expanded(
                        flex: 2,
                        child: _OperationTypeBadge(type: operation.type),
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

class _MobileHistoryList extends StatelessWidget {
  const _MobileHistoryList({required this.operations});

  final List<StockOperation> operations;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
                    _OperationTypeBadge(type: operation.type),
                    Text(_formatDateTime(operation.createdAt)),
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

class _WarehouseDropdown extends StatelessWidget {
  const _WarehouseDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.warehouses,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<Warehouse> warehouses;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: warehouses
          .map<DropdownMenuItem<String>>(
            (warehouse) => DropdownMenuItem<String>(
              value: warehouse.id,
              child: Text('${warehouse.name} (${warehouse.location})'),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class _ProductDropdown extends StatelessWidget {
  const _ProductDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.products,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<ProductStock> products;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: products
          .map(
            (stock) => DropdownMenuItem<String>(
              value: stock.productId,
              child: Text('${stock.productName} (${stock.availableQuantity})'),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  const _DashboardActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileActionTile extends StatelessWidget {
  const _MobileActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.secondaryContainer.withValues(alpha: 0.55),
    );
  }
}

class _OperationTypeBadge extends StatelessWidget {
  const _OperationTypeBadge({required this.type});

  final StockOperationType type;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;

    switch (type) {
      case StockOperationType.transfer:
        color = Colors.blue.shade100;
        text = 'TRANSFER';
        break;
      case StockOperationType.damaged:
        color = Colors.orange.shade200;
        text = 'DAMAGED';
        break;
      case StockOperationType.expired:
        color = Colors.red.shade200;
        text = 'EXPIRED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day $hour:$minute';
}

extension on _StockOperationsScreenState {
  String _mobileTitleForAction(StockDashboardAction action) {
    switch (action.view) {
      case StockOperationsView.dashboard:
        return 'Stock Operations Dashboard';
      case StockOperationsView.transfer:
        return 'Internal Stock Transfer';
      case StockOperationsView.damagedGoods:
        return 'Damaged / Expired Goods';
      case StockOperationsView.history:
        return 'Operation History';
    }
  }

  String _mobileSubtitleForAction(StockDashboardAction action) {
    switch (action.view) {
      case StockOperationsView.dashboard:
        return 'Stock operations overview.';
      case StockOperationsView.transfer:
        return 'Move stock between warehouses.';
      case StockOperationsView.damagedGoods:
        return 'Record damaged and expired goods.';
      case StockOperationsView.history:
        return 'Read-only local operation logs.';
    }
  }

  Widget _mobileChildForAction(StockDashboardAction action) {
    switch (action.view) {
      case StockOperationsView.dashboard:
        return _StockDashboardPanel(store: _store, onNavigate: _store.setCurrentView);
      case StockOperationsView.transfer:
        return _TransferPanel(store: _store, isDesktop: false);
      case StockOperationsView.damagedGoods:
        return _DamagedExpiredPanel(store: _store);
      case StockOperationsView.history:
        return _OperationHistoryPanel(store: _store, isDesktop: false);
    }
  }
}

