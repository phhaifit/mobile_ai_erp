import 'dart:async';

import 'package:mobile_ai_erp/presentation/reports/model/reports_models.dart';

class ReportsMockRepository {
  Future<ReportsDashboardData> loadDashboard(ReportFilter filter) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return ReportsDashboardData(
      filter: filter,
      salesKpis: const [
        ReportKpi(
          title: 'Net sales',
          value: '\$184.2K',
          changeLabel: '+12.4% vs last period',
          isPositive: true,
        ),
        ReportKpi(
          title: 'Orders fulfilled',
          value: '1,284',
          changeLabel: '+8.1% operational lift',
          isPositive: true,
        ),
        ReportKpi(
          title: 'Gross margin',
          value: '41.8%',
          changeLabel: '+2.6 pts efficiency gain',
          isPositive: true,
        ),
        ReportKpi(
          title: 'Returns',
          value: '2.3%',
          changeLabel: '-0.7 pts quality improvement',
          isPositive: true,
        ),
      ],
      trendPoints: _trendPointsFor(filter.period),
      salesBreakdowns: const [
        SalesBreakdown(
          label: 'Website',
          value: '\$96.4K',
          shareLabel: '52% share',
        ),
        SalesBreakdown(
          label: 'Shopee',
          value: '\$51.7K',
          shareLabel: '28% share',
        ),
        SalesBreakdown(
          label: 'Lazada',
          value: '\$24.3K',
          shareLabel: '13% share',
        ),
        SalesBreakdown(
          label: 'Facebook',
          value: '\$11.8K',
          shareLabel: '7% share',
        ),
      ],
      topProducts: const [
        ProductPerformanceItem(
          name: 'AeroBottle 750ml',
          revenue: '\$28.4K',
          unitsSold: 634,
          conversionRate: '7.4%',
          trendLabel: '+14%',
        ),
        ProductPerformanceItem(
          name: 'Urban Sling Pack',
          revenue: '\$24.9K',
          unitsSold: 451,
          conversionRate: '6.1%',
          trendLabel: '+11%',
        ),
        ProductPerformanceItem(
          name: 'ThermaCup Mini',
          revenue: '\$17.2K',
          unitsSold: 392,
          conversionRate: '5.7%',
          trendLabel: '+8%',
        ),
      ],
      lowPerformers: const [
        ProductPerformanceItem(
          name: 'Canvas Desk Tray',
          revenue: '\$2.1K',
          unitsSold: 49,
          conversionRate: '1.2%',
          trendLabel: '-9%',
        ),
        ProductPerformanceItem(
          name: 'Foldable Stand Pro',
          revenue: '\$1.6K',
          unitsSold: 31,
          conversionRate: '0.9%',
          trendLabel: '-13%',
        ),
      ],
      inventoryItems: const [
        InventoryReportItem(
          label: 'Healthy stock coverage',
          value: '74%',
          context: '246 active SKUs within target days on hand',
          severity: ReportSeverity.good,
        ),
        InventoryReportItem(
          label: 'Low stock alerts',
          value: '18 SKUs',
          context: 'Reorder within 7 days for fast movers',
          severity: ReportSeverity.warning,
        ),
        InventoryReportItem(
          label: 'Overstock exposure',
          value: '\$12.7K',
          context: 'Dormant inventory above 60 days',
          severity: ReportSeverity.warning,
        ),
        InventoryReportItem(
          label: 'Aging risk',
          value: '7 lots',
          context: 'Approaching expiry or markdown threshold',
          severity: ReportSeverity.critical,
        ),
      ],
      profitAndLoss: const [
        ProfitLossRow(label: 'Revenue', amount: '\$184,200'),
        ProfitLossRow(label: 'Cost of goods sold', amount: '-\$107,300'),
        ProfitLossRow(
          label: 'Gross profit',
          amount: '\$76,900',
          highlight: true,
        ),
        ProfitLossRow(label: 'Marketing', amount: '-\$12,400'),
        ProfitLossRow(label: 'Fulfillment', amount: '-\$9,100'),
        ProfitLossRow(label: 'Operations', amount: '-\$14,600'),
        ProfitLossRow(
          label: 'Net profit',
          amount: '\$40,800',
          highlight: true,
        ),
      ],
      exportTemplates: const [
        ExportTemplate(
          title: 'Executive summary pack',
          description: 'Sales, inventory, and P&L snapshot for leadership.',
          formats: ['PDF', 'CSV'],
        ),
        ExportTemplate(
          title: 'Product performance dump',
          description: 'SKU-level sales, revenue, and conversion data.',
          formats: ['CSV', 'XLSX'],
        ),
        ExportTemplate(
          title: 'Inventory action board',
          description: 'Low stock, aging stock, and replenishment priorities.',
          formats: ['CSV'],
        ),
      ],
      exportJobs: const [
        ExportJob(
          title: 'Weekly board report',
          format: 'PDF',
          updatedAt: 'Generated 2 hours ago',
          status: ExportJobStatus.completed,
        ),
        ExportJob(
          title: 'Inventory risk snapshot',
          format: 'CSV',
          updatedAt: 'Ready to export',
          status: ExportJobStatus.ready,
        ),
        ExportJob(
          title: 'Marketplace sales extract',
          format: 'XLSX',
          updatedAt: 'Processing mock job',
          status: ExportJobStatus.processing,
        ),
      ],
      insights: const [
        AiInsight(
          title: 'Demand pulse',
          summary:
              'Bottle accessories are compounding fastest on website traffic, suggesting a strong bundle opportunity.',
        ),
        AiInsight(
          title: 'Margin watch',
          summary:
              'Shopee orders are growing, but discount depth is reducing contribution margin more than fulfillment gains.',
        ),
        AiInsight(
          title: 'Inventory action',
          summary:
              'Replenish 18 fast-moving SKUs this week and mark down 7 aging lots to protect cash flow.',
        ),
      ],
    );
  }

  static List<TrendPoint> _trendPointsFor(ReportPeriod period) {
    switch (period) {
      case ReportPeriod.weekly:
        return const [
          TrendPoint(label: 'Mon', value: 18),
          TrendPoint(label: 'Tue', value: 22),
          TrendPoint(label: 'Wed', value: 21),
          TrendPoint(label: 'Thu', value: 28),
          TrendPoint(label: 'Fri', value: 31),
          TrendPoint(label: 'Sat', value: 26),
          TrendPoint(label: 'Sun', value: 24),
        ];
      case ReportPeriod.monthly:
        return const [
          TrendPoint(label: 'W1', value: 64),
          TrendPoint(label: 'W2', value: 72),
          TrendPoint(label: 'W3', value: 70),
          TrendPoint(label: 'W4', value: 84),
        ];
      case ReportPeriod.quarterly:
        return const [
          TrendPoint(label: 'Jan', value: 132),
          TrendPoint(label: 'Feb', value: 148),
          TrendPoint(label: 'Mar', value: 184),
        ];
      case ReportPeriod.yearly:
        return const [
          TrendPoint(label: 'Q1', value: 420),
          TrendPoint(label: 'Q2', value: 455),
          TrendPoint(label: 'Q3', value: 512),
          TrendPoint(label: 'Q4', value: 548),
        ];
    }
  }
}
