import 'package:mobile_ai_erp/data/network/dto/dashboard/dashboard_snapshot_dto.dart';
import 'package:mobile_ai_erp/domain/entity/dashboard/dashboard_entities.dart';

/// Maps backend DTOs (DashboardSnapshotDto) into domain models.
///
/// Enum strings from the backend are mapped to their matching Dart enum values.
/// The backend contract is the source of truth for field names and types.
class DashboardMapper {
  /// Converts the full snapshot DTO to a domain [DashboardSnapshot].
  static DashboardSnapshot fromDto(DashboardSnapshotDto dto) {
    return DashboardSnapshot(
      kpis: dto.kpis.map(_mapKpi).toList(growable: false),
      pendingTasks: dto.pendingTasks.map(_mapTask).toList(growable: false),
      salesSeries:
          dto.salesSeries.map(_mapSalesPoint).toList(growable: false),
      insights: dto.insights.map(_mapInsight).toList(growable: false),
      quickNavItems:
          dto.quickNavItems.map(_mapQuickNav).toList(growable: false),
      period: _mapPeriod(dto.period),
      generatedAt: DateTime.parse(dto.generatedAt),
    );
  }

  static DashboardKpi _mapKpi(DashboardKpiDto dto) {
    return DashboardKpi(
      id: dto.id,
      label: dto.label,
      value: dto.value,
      deltaPercent: dto.deltaPercent,
      trend: _mapTrendDirection(dto.trend),
    );
  }

  static PendingTaskItem _mapTask(PendingTaskItemDto dto) {
    return PendingTaskItem(
      id: dto.id,
      title: dto.title,
      module: dto.module,
      priority: _mapTaskPriority(dto.priority),
      dueAt: DateTime.parse(dto.dueAt),
      assignee: dto.assignee,
      isOverdue: dto.isOverdue,
    );
  }

  static SalesDataPoint _mapSalesPoint(SalesDataPointDto dto) {
    return SalesDataPoint(
      label: dto.label,
      value: dto.value,
      secondaryValue: dto.secondaryValue,
      timestamp: dto.timestamp != null ? DateTime.parse(dto.timestamp!) : null,
    );
  }

  static InsightItem _mapInsight(InsightItemDto dto) {
    return InsightItem(
      id: dto.id,
      title: dto.title,
      summary: dto.summary,
      category: _mapInsightCategory(dto.category),
      severity: _mapInsightSeverity(dto.severity),
      generatedAt: DateTime.parse(dto.generatedAt),
      tags: dto.tags,
    );
  }

  static QuickNavItem _mapQuickNav(QuickNavItemDto dto) {
    return QuickNavItem(
      id: dto.id,
      label: dto.label,
      target: _mapQuickTarget(dto.target),
      badgeCount: dto.badgeCount,
    );
  }

  // ---------------------------------------------------------------------------
  // Enum helpers – keep in sync with domain enums & backend DTO strings
  // ---------------------------------------------------------------------------

  static DashboardTrendDirection _mapTrendDirection(String value) {
    switch (value) {
      case 'up':
        return DashboardTrendDirection.up;
      case 'down':
        return DashboardTrendDirection.down;
      default:
        return DashboardTrendDirection.neutral;
    }
  }

  static DashboardTaskPriority _mapTaskPriority(String value) {
    switch (value) {
      case 'low':
        return DashboardTaskPriority.low;
      case 'medium':
        return DashboardTaskPriority.medium;
      case 'high':
        return DashboardTaskPriority.high;
      case 'critical':
        return DashboardTaskPriority.critical;
      default:
        return DashboardTaskPriority.medium;
    }
  }

  static DashboardInsightCategory _mapInsightCategory(String value) {
    switch (value) {
      case 'opportunity':
        return DashboardInsightCategory.opportunity;
      case 'risk':
        return DashboardInsightCategory.risk;
      case 'highlight':
        return DashboardInsightCategory.highlight;
      default:
        return DashboardInsightCategory.highlight;
    }
  }

  static DashboardInsightSeverity _mapInsightSeverity(String value) {
    switch (value) {
      case 'info':
        return DashboardInsightSeverity.info;
      case 'warning':
        return DashboardInsightSeverity.warning;
      case 'critical':
        return DashboardInsightSeverity.critical;
      default:
        return DashboardInsightSeverity.info;
    }
  }

  static DashboardPeriod _mapPeriod(String value) {
    switch (value) {
      case 'daily':
        return DashboardPeriod.daily;
      case 'weekly':
        return DashboardPeriod.weekly;
      case 'monthly':
        return DashboardPeriod.monthly;
      default:
        return DashboardPeriod.weekly;
    }
  }

  static DashboardQuickTarget _mapQuickTarget(String value) {
    switch (value) {
      case 'products':
        return DashboardQuickTarget.products;
      case 'stockOperations':
        return DashboardQuickTarget.stockOperations;
      case 'orders':
        return DashboardQuickTarget.orders;
      case 'suppliers':
        return DashboardQuickTarget.suppliers;
      case 'reports':
        return DashboardQuickTarget.reports;
      default:
        return DashboardQuickTarget.products;
    }
  }
}
