enum DashboardTrendDirection { up, down, neutral }

enum DashboardTaskPriority { low, medium, high, critical }

enum DashboardInsightSeverity { info, warning, critical }

enum DashboardInsightCategory { opportunity, risk, highlight }

enum DashboardPeriod { daily, weekly, monthly }

enum DashboardQuickTarget {
  products,
  stockOperations,
  orders,
  suppliers,
  reports,
}

class DashboardKpi {
  const DashboardKpi({
    required this.id,
    required this.label,
    required this.value,
    required this.deltaPercent,
    required this.trend,
  });

  final String id;
  final String label;
  final String value;
  final double deltaPercent;
  final DashboardTrendDirection trend;
}

class PendingTaskItem {
  const PendingTaskItem({
    required this.id,
    required this.title,
    required this.module,
    required this.priority,
    required this.dueAt,
    this.assignee,
    this.isOverdue = false,
  });

  final String id;
  final String title;
  final String module;
  final DashboardTaskPriority priority;
  final DateTime dueAt;
  final String? assignee;
  final bool isOverdue;
}

class SalesDataPoint {
  const SalesDataPoint({
    required this.label,
    required this.value,
    this.secondaryValue,
    this.timestamp,
  });

  final String label;
  final double value;
  final double? secondaryValue;
  final DateTime? timestamp;
}

class InsightItem {
  const InsightItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.severity,
    required this.generatedAt,
    this.tags = const <String>[],
  });

  final String id;
  final String title;
  final String summary;
  final DashboardInsightCategory category;
  final DashboardInsightSeverity severity;
  final DateTime generatedAt;
  final List<String> tags;
}

class QuickNavItem {
  const QuickNavItem({
    required this.id,
    required this.label,
    required this.target,
    this.badgeCount,
  });

  final String id;
  final String label;
  final DashboardQuickTarget target;
  final int? badgeCount;
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.kpis,
    required this.pendingTasks,
    required this.salesSeries,
    required this.insights,
    required this.quickNavItems,
    required this.period,
    required this.generatedAt,
  });

  final List<DashboardKpi> kpis;
  final List<PendingTaskItem> pendingTasks;
  final List<SalesDataPoint> salesSeries;
  final List<InsightItem> insights;
  final List<QuickNavItem> quickNavItems;
  final DashboardPeriod period;
  final DateTime generatedAt;
}
