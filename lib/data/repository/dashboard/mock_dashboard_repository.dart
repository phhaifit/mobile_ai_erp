import 'dart:async';

import 'package:mobile_ai_erp/domain/entity/dashboard/dashboard_entities.dart';
import 'package:mobile_ai_erp/domain/repository/dashboard/dashboard_repository.dart';

class MockDashboardRepository extends DashboardRepository {
  @override
  Future<DashboardSnapshot> loadDashboard(DashboardPeriod period) async {
    final now = DateTime.now();

    return DashboardSnapshot(
      kpis: const [
        DashboardKpi(
          id: 'kpi-revenue',
          label: 'Revenue',
          value: '4.8M USD',
          deltaPercent: 8.4,
          trend: DashboardTrendDirection.up,
        ),
        DashboardKpi(
          id: 'kpi-orders',
          label: 'Orders',
          value: '1,284',
          deltaPercent: 4.1,
          trend: DashboardTrendDirection.up,
        ),
        DashboardKpi(
          id: 'kpi-low-stock',
          label: 'Low Stock Alerts',
          value: '18',
          deltaPercent: -2.0,
          trend: DashboardTrendDirection.down,
        ),
        DashboardKpi(
          id: 'kpi-on-time',
          label: 'On-Time Fulfillment',
          value: '94%',
          deltaPercent: 1.2,
          trend: DashboardTrendDirection.up,
        ),
      ],
      pendingTasks: _pendingTasks(now),
      salesSeries: _seriesFor(period),
      insights: _insights(now),
      quickNavItems: const [
        QuickNavItem(
          id: 'quick-products',
          label: 'Products',
          target: DashboardQuickTarget.products,
        ),
        QuickNavItem(
          id: 'quick-stock',
          label: 'Stock Ops',
          target: DashboardQuickTarget.stockOperations,
          badgeCount: 3,
        ),
        QuickNavItem(
          id: 'quick-orders',
          label: 'Orders',
          target: DashboardQuickTarget.orders,
          badgeCount: 5,
        ),
        QuickNavItem(
          id: 'quick-suppliers',
          label: 'Suppliers',
          target: DashboardQuickTarget.suppliers,
        ),
        QuickNavItem(
          id: 'quick-reports',
          label: 'Reports',
          target: DashboardQuickTarget.reports,
        ),
      ],
      period: period,
      generatedAt: now,
    );
  }

  List<SalesDataPoint> _seriesFor(DashboardPeriod period) {
    switch (period) {
      case DashboardPeriod.daily:
        return const [
          SalesDataPoint(label: '8 AM', value: 52),
          SalesDataPoint(label: '10 AM', value: 80),
          SalesDataPoint(label: '12 PM', value: 108),
          SalesDataPoint(label: '2 PM', value: 122),
          SalesDataPoint(label: '4 PM', value: 132),
          SalesDataPoint(label: '6 PM', value: 117),
        ];
      case DashboardPeriod.weekly:
        return const [
          SalesDataPoint(label: 'Mon', value: 356),
          SalesDataPoint(label: 'Tue', value: 402),
          SalesDataPoint(label: 'Wed', value: 445),
          SalesDataPoint(label: 'Thu', value: 410),
          SalesDataPoint(label: 'Fri', value: 468),
          SalesDataPoint(label: 'Sat', value: 512),
          SalesDataPoint(label: 'Sun', value: 490),
        ];
      case DashboardPeriod.monthly:
        return const [
          SalesDataPoint(label: 'W1', value: 1650),
          SalesDataPoint(label: 'W2', value: 1820),
          SalesDataPoint(label: 'W3', value: 1940),
          SalesDataPoint(label: 'W4', value: 2015),
        ];
    }
  }

  List<PendingTaskItem> _pendingTasks(DateTime now) {
    return [
      PendingTaskItem(
        id: 'task-001',
        title: 'Approve 3 inbound receipts',
        module: 'Inventory',
        priority: DashboardTaskPriority.high,
        dueAt: now.add(const Duration(hours: 2)),
      ),
      PendingTaskItem(
        id: 'task-002',
        title: 'Resolve delayed shipments',
        module: 'Orders',
        priority: DashboardTaskPriority.critical,
        dueAt: now.subtract(const Duration(minutes: 50)),
        isOverdue: true,
      ),
      PendingTaskItem(
        id: 'task-003',
        title: 'Review supplier SLA report',
        module: 'Suppliers',
        priority: DashboardTaskPriority.medium,
        dueAt: now.add(const Duration(hours: 5)),
      ),
    ];
  }

  List<InsightItem> _insights(DateTime now) {
    return [
      InsightItem(
        id: 'ins-001',
        title: 'Demand pulse',
        summary:
            'Accessories category is outpacing forecast by 14% this week.',
        category: DashboardInsightCategory.opportunity,
        severity: DashboardInsightSeverity.info,
        generatedAt: now.subtract(const Duration(minutes: 30)),
        tags: const ['sales', 'forecast'],
      ),
      InsightItem(
        id: 'ins-002',
        title: 'Margin watch',
        summary:
            'Discount depth on flash sale SKUs increased by 6 points.',
        category: DashboardInsightCategory.risk,
        severity: DashboardInsightSeverity.warning,
        generatedAt: now.subtract(const Duration(hours: 2)),
        tags: const ['margin', 'promotion'],
      ),
      InsightItem(
        id: 'ins-003',
        title: 'Warehouse pressure',
        summary:
            'North warehouse utilization crossed 92%; rebalance transfer suggested.',
        category: DashboardInsightCategory.highlight,
        severity: DashboardInsightSeverity.critical,
        generatedAt: now.subtract(const Duration(hours: 4)),
        tags: const ['warehouse', 'capacity'],
      ),
    ];
  }
}
