enum ReportPeriod { weekly, monthly, quarterly, yearly }

class ReportFilter {
  const ReportFilter({
    required this.label,
    required this.period,
    required this.dateRangeLabel,
  });

  final String label;
  final ReportPeriod period;
  final String dateRangeLabel;

  ReportFilter copyWith({
    String? label,
    ReportPeriod? period,
    String? dateRangeLabel,
  }) {
    return ReportFilter(
      label: label ?? this.label,
      period: period ?? this.period,
      dateRangeLabel: dateRangeLabel ?? this.dateRangeLabel,
    );
  }
}

class ReportKpi {
  const ReportKpi({
    required this.title,
    required this.value,
    required this.changeLabel,
    required this.isPositive,
  });

  final String title;
  final String value;
  final String changeLabel;
  final bool isPositive;
}

class TrendPoint {
  const TrendPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}

class SalesBreakdown {
  const SalesBreakdown({
    required this.label,
    required this.value,
    required this.shareLabel,
  });

  final String label;
  final String value;
  final String shareLabel;
}

class ProductPerformanceItem {
  const ProductPerformanceItem({
    required this.name,
    required this.revenue,
    required this.unitsSold,
    required this.conversionRate,
    required this.trendLabel,
  });

  final String name;
  final String revenue;
  final int unitsSold;
  final String conversionRate;
  final String trendLabel;
}

class InventoryReportItem {
  const InventoryReportItem({
    required this.label,
    required this.value,
    required this.context,
    required this.severity,
  });

  final String label;
  final String value;
  final String context;
  final ReportSeverity severity;
}

enum ReportSeverity { good, warning, critical }

class ProfitLossRow {
  const ProfitLossRow({
    required this.label,
    required this.amount,
    this.highlight = false,
  });

  final String label;
  final String amount;
  final bool highlight;
}

class ExportTemplate {
  const ExportTemplate({
    required this.title,
    required this.description,
    required this.formats,
  });

  final String title;
  final String description;
  final List<String> formats;
}

enum ExportJobStatus { ready, processing, completed }

class ExportJob {
  const ExportJob({
    required this.title,
    required this.format,
    required this.updatedAt,
    required this.status,
  });

  final String title;
  final String format;
  final String updatedAt;
  final ExportJobStatus status;

  ExportJob copyWith({
    String? title,
    String? format,
    String? updatedAt,
    ExportJobStatus? status,
  }) {
    return ExportJob(
      title: title ?? this.title,
      format: format ?? this.format,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }
}

class AiInsight {
  const AiInsight({
    required this.title,
    required this.summary,
  });

  final String title;
  final String summary;
}

class ReportsDashboardData {
  const ReportsDashboardData({
    required this.filter,
    required this.salesKpis,
    required this.trendPoints,
    required this.salesBreakdowns,
    required this.topProducts,
    required this.lowPerformers,
    required this.inventoryItems,
    required this.profitAndLoss,
    required this.exportTemplates,
    required this.exportJobs,
    required this.insights,
  });

  final ReportFilter filter;
  final List<ReportKpi> salesKpis;
  final List<TrendPoint> trendPoints;
  final List<SalesBreakdown> salesBreakdowns;
  final List<ProductPerformanceItem> topProducts;
  final List<ProductPerformanceItem> lowPerformers;
  final List<InventoryReportItem> inventoryItems;
  final List<ProfitLossRow> profitAndLoss;
  final List<ExportTemplate> exportTemplates;
  final List<ExportJob> exportJobs;
  final List<AiInsight> insights;

  ReportsDashboardData copyWith({
    ReportFilter? filter,
    List<ReportKpi>? salesKpis,
    List<TrendPoint>? trendPoints,
    List<SalesBreakdown>? salesBreakdowns,
    List<ProductPerformanceItem>? topProducts,
    List<ProductPerformanceItem>? lowPerformers,
    List<InventoryReportItem>? inventoryItems,
    List<ProfitLossRow>? profitAndLoss,
    List<ExportTemplate>? exportTemplates,
    List<ExportJob>? exportJobs,
    List<AiInsight>? insights,
  }) {
    return ReportsDashboardData(
      filter: filter ?? this.filter,
      salesKpis: salesKpis ?? this.salesKpis,
      trendPoints: trendPoints ?? this.trendPoints,
      salesBreakdowns: salesBreakdowns ?? this.salesBreakdowns,
      topProducts: topProducts ?? this.topProducts,
      lowPerformers: lowPerformers ?? this.lowPerformers,
      inventoryItems: inventoryItems ?? this.inventoryItems,
      profitAndLoss: profitAndLoss ?? this.profitAndLoss,
      exportTemplates: exportTemplates ?? this.exportTemplates,
      exportJobs: exportJobs ?? this.exportJobs,
      insights: insights ?? this.insights,
    );
  }
}
