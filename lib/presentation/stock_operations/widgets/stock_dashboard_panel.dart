import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/store/stock_operations_store.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/widgets/stock_operations_shared_widgets.dart';

class StockDashboardPanel extends StatelessWidget {
  const StockDashboardPanel({
    super.key,
    required this.store,
    required this.onNavigate,
  });

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
        DashboardSummary(store: store),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: store.dashboardActions
                .map(
                  (action) => DashboardActionCard(
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

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({super.key, required this.store});

  final StockOperationsStore store;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SummaryChip(
              label: 'Total Operations',
              value: '${store.totalOperationsCount}',
            ),
            SummaryChip(
              label: 'Damaged',
              value: '${store.damagedOperationsCount}',
            ),
            SummaryChip(
              label: 'Expired',
              value: '${store.expiredOperationsCount}',
            ),
          ],
        );
      },
    );
  }
}
