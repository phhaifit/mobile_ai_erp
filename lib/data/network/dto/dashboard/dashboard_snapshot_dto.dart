import 'package:json_annotation/json_annotation.dart';

part 'dashboard_snapshot_dto.g.dart';

// ---------------------------------------------------------------------------
// DTOs mirroring the backend snapshot contract exactly.
// Backend endpoint: GET /erp/dashboard/snapshot?period=daily|weekly|monthly
// ---------------------------------------------------------------------------

@JsonSerializable()
class DashboardKpiDto {
  final String id;
  final String label;
  final String value;
  final double deltaPercent;
  final String trend;

  const DashboardKpiDto({
    required this.id,
    required this.label,
    required this.value,
    required this.deltaPercent,
    required this.trend,
  });

  factory DashboardKpiDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardKpiDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardKpiDtoToJson(this);
}

@JsonSerializable()
class PendingTaskItemDto {
  final String id;
  final String title;
  final String module;
  final String priority;
  final String dueAt;
  final String? assignee;
  final bool isOverdue;

  const PendingTaskItemDto({
    required this.id,
    required this.title,
    required this.module,
    required this.priority,
    required this.dueAt,
    this.assignee,
    required this.isOverdue,
  });

  factory PendingTaskItemDto.fromJson(Map<String, dynamic> json) =>
      _$PendingTaskItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PendingTaskItemDtoToJson(this);
}

@JsonSerializable()
class SalesDataPointDto {
  final String label;
  final double value;
  final double? secondaryValue;
  final String? timestamp;

  const SalesDataPointDto({
    required this.label,
    required this.value,
    this.secondaryValue,
    this.timestamp,
  });

  factory SalesDataPointDto.fromJson(Map<String, dynamic> json) =>
      _$SalesDataPointDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SalesDataPointDtoToJson(this);
}

@JsonSerializable()
class InsightItemDto {
  final String id;
  final String title;
  final String summary;
  final String category;
  final String severity;
  final String generatedAt;
  final List<String> tags;

  const InsightItemDto({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.severity,
    required this.generatedAt,
    this.tags = const <String>[],
  });

  factory InsightItemDto.fromJson(Map<String, dynamic> json) =>
      _$InsightItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$InsightItemDtoToJson(this);
}

@JsonSerializable()
class QuickNavItemDto {
  final String id;
  final String label;
  final String target;
  final int? badgeCount;

  const QuickNavItemDto({
    required this.id,
    required this.label,
    required this.target,
    this.badgeCount,
  });

  factory QuickNavItemDto.fromJson(Map<String, dynamic> json) =>
      _$QuickNavItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QuickNavItemDtoToJson(this);
}

@JsonSerializable()
class DashboardSnapshotDto {
  final List<DashboardKpiDto> kpis;
  final List<PendingTaskItemDto> pendingTasks;
  final List<SalesDataPointDto> salesSeries;
  final List<InsightItemDto> insights;
  final List<QuickNavItemDto> quickNavItems;
  final String period;
  final String generatedAt;

  const DashboardSnapshotDto({
    required this.kpis,
    required this.pendingTasks,
    required this.salesSeries,
    required this.insights,
    required this.quickNavItems,
    required this.period,
    required this.generatedAt,
  });

  factory DashboardSnapshotDto.fromJson(Map<String, dynamic> json) =>
      _$DashboardSnapshotDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardSnapshotDtoToJson(this);
}
