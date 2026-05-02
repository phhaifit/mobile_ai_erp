import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/store/stock_operations_store.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/widgets/damaged_expired_panel.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/widgets/operation_history_panel.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/widgets/stock_dashboard_panel.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/widgets/stock_operations_shared_widgets.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/widgets/transfer_panel.dart';

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
                DashboardSummary(store: _store),
                const SizedBox(height: 16),
                ..._store.dashboardActions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MobileActionTile(
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
        return StockDashboardPanel(
          store: _store,
          onNavigate: _store.setCurrentView,
        );
      case StockOperationsView.transfer:
        return TransferPanel(store: _store, isDesktop: true);
      case StockOperationsView.damagedGoods:
        return DamagedExpiredPanel(store: _store);
      case StockOperationsView.history:
        return OperationHistoryPanel(store: _store, isDesktop: true);
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
        return 'Review synced stock movement and disposal history.';
    }
  }

  Widget _mobileChildForAction(StockDashboardAction action) {
    switch (action.view) {
      case StockOperationsView.dashboard:
        return StockDashboardPanel(
          store: _store,
          onNavigate: _store.setCurrentView,
        );
      case StockOperationsView.transfer:
        return TransferPanel(store: _store, isDesktop: false);
      case StockOperationsView.damagedGoods:
        return DamagedExpiredPanel(store: _store);
      case StockOperationsView.history:
        return OperationHistoryPanel(store: _store, isDesktop: false);
    }
  }
}
