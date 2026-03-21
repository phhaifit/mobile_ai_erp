import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/reports/model/reports_models.dart';
import 'package:mobile_ai_erp/presentation/reports/store/reports_store.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  ReportsAnalyticsScreen({super.key, ReportsStore? store})
      : store = store ?? getIt<ReportsStore>();

  final ReportsStore store;

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  ReportsStore get _store => widget.store;

  @override
  void initState() {
    super.initState();
    if (_store.dashboard == null) {
      Future<void>.microtask(_store.loadDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: Observer(
        builder: (context) {
          final dashboard = _store.dashboard;
          if (_store.isLoading && dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboard == null) {
            return const Center(child: Text('No report data available.'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ReportsHero(
                    filter: _store.selectedFilter,
                    insights: dashboard.insights,
                    onPeriodSelected: _store.changePeriod,
                  ),
                  const SizedBox(height: 16),
                  _KpiGrid(
                    kpis: dashboard.salesKpis,
                    columns: isWide ? 4 : 2,
                  ),
                  const SizedBox(height: 16),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _ReportsSectionCard(
                            title: 'Sales analytics',
                            subtitle:
                                'Revenue momentum, channel mix, and order health.',
                            child: _SalesAnalyticsSection(dashboard: dashboard),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _ReportsSectionCard(
                            title: 'Inventory reports',
                            subtitle:
                                'Coverage, low stock, overstock, and aging risk.',
                            child: _InventorySection(
                                items: dashboard.inventoryItems),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _ReportsSectionCard(
                      title: 'Sales analytics',
                      subtitle:
                          'Revenue momentum, channel mix, and order health.',
                      child: _SalesAnalyticsSection(dashboard: dashboard),
                    ),
                    const SizedBox(height: 16),
                    _ReportsSectionCard(
                      title: 'Inventory reports',
                      subtitle:
                          'Coverage, low stock, overstock, and aging risk.',
                      child: _InventorySection(items: dashboard.inventoryItems),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ReportsSectionCard(
                            title: 'Product performance',
                            subtitle:
                                'Winners, laggards, conversion and revenue by SKU.',
                            child: _ProductPerformanceSection(
                              topProducts: dashboard.topProducts,
                              lowPerformers: dashboard.lowPerformers,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ReportsSectionCard(
                            title: 'Financial report (P&L)',
                            subtitle: 'Snapshot of revenue, costs, and profit.',
                            child: _ProfitLossSection(
                                rows: dashboard.profitAndLoss),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _ReportsSectionCard(
                      title: 'Product performance',
                      subtitle:
                          'Winners, laggards, conversion and revenue by SKU.',
                      child: _ProductPerformanceSection(
                        topProducts: dashboard.topProducts,
                        lowPerformers: dashboard.lowPerformers,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ReportsSectionCard(
                      title: 'Financial report (P&L)',
                      subtitle: 'Snapshot of revenue, costs, and profit.',
                      child: _ProfitLossSection(rows: dashboard.profitAndLoss),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _ReportsSectionCard(
                    title: 'Data export center',
                    subtitle:
                        'Launch mock exports and review generated report packages.',
                    trailing: FilledButton.icon(
                      onPressed: dashboard.exportJobs.isEmpty
                          ? null
                          : () => _store.exportJob(0),
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Export now'),
                    ),
                    child: _ExportSection(
                      templates: dashboard.exportTemplates,
                      jobs: dashboard.exportJobs,
                      onRunExport: _store.exportJob,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ReportsHero extends StatelessWidget {
  const _ReportsHero({
    required this.filter,
    required this.insights,
    required this.onPeriodSelected,
  });

  final ReportFilter filter;
  final List<AiInsight> insights;
  final ValueChanged<ReportPeriod> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chipValues = ReportPeriod.values;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.16),
            colorScheme.secondary.withValues(alpha: 0.28),
            colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comprehensive reporting across sales, inventory, products, and financials.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${filter.label} • ${filter.dateRangeLabel}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => onPeriodSelected(filter.period),
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Refresh AI summary'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chipValues.map((period) {
              return ChoiceChip(
                label: Text(_periodLabel(period)),
                selected: filter.period == period,
                onSelected: (_) => onPeriodSelected(period),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: insights
                .map((insight) => _InsightCard(insight: insight))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.kpis,
    required this.columns,
  });

  final List<ReportKpi> kpis;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: kpis.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: columns == 4 ? 1.45 : 1.2,
      ),
      itemBuilder: (context, index) {
        final item = kpis[index];
        final trendColor = item.isPositive ? Colors.green : Colors.redAccent;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.title, style: Theme.of(context).textTheme.titleMedium),
              Text(item.value,
                  style: Theme.of(context).textTheme.headlineMedium),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.changeLabel,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: trendColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReportsSectionCard extends StatelessWidget {
  const _ReportsSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SalesAnalyticsSection extends StatelessWidget {
  const _SalesAnalyticsSection({required this.dashboard});

  final ReportsDashboardData dashboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: _MockTrendChart(points: dashboard.trendPoints),
        ),
        const SizedBox(height: 16),
        ...dashboard.salesBreakdowns.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(item.shareLabel),
                const SizedBox(width: 16),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InventorySection extends StatelessWidget {
  const _InventorySection({required this.items});

  final List<InventoryReportItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _severityColor(item.severity).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: _severityColor(item.severity),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(item.context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.value,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ProductPerformanceSection extends StatelessWidget {
  const _ProductPerformanceSection({
    required this.topProducts,
    required this.lowPerformers,
  });

  final List<ProductPerformanceItem> topProducts;
  final List<ProductPerformanceItem> lowPerformers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top products', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ...topProducts.map((item) => _ProductRow(item: item, positive: true)),
        const SizedBox(height: 14),
        Text('Low performers', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ...lowPerformers
            .map((item) => _ProductRow(item: item, positive: false)),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.item,
    required this.positive,
  });

  final ProductPerformanceItem item;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? Colors.green : Colors.orangeAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                    '${item.unitsSold} units • ${item.conversionRate} conversion'),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.revenue,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                item.trendLabel,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfitLossSection extends StatelessWidget {
  const _ProfitLossSection({required this.rows});

  final List<ProfitLossRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows
          .map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.label,
                      style: row.highlight
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    row.amount,
                    style: (row.highlight
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context).textTheme.titleMedium)
                        ?.copyWith(
                      color: row.amount.startsWith('-')
                          ? Colors.redAccent
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ExportSection extends StatelessWidget {
  const _ExportSection({
    required this.templates,
    required this.jobs,
    required this.onRunExport,
  });

  final List<ExportTemplate> templates;
  final List<ExportJob> jobs;
  final ValueChanged<int> onRunExport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Templates', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ...templates.map(
          (template) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(template.description),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: template.formats
                      .map(
                        (format) => Chip(
                          label: Text(format),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Recent export jobs',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        ...jobs.asMap().entries.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                              '${entry.value.format} • ${entry.value.updatedAt}'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(_jobLabel(entry.value.status)),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => onRunExport(entry.key),
                      child: const Text('Run'),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final AiInsight insight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(insight.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(insight.summary),
          ],
        ),
      ),
    );
  }
}

class _MockTrendChart extends StatelessWidget {
  const _MockTrendChart({required this.points});

  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrendChartPainter(
        points: points,
        lineColor: Theme.of(context).colorScheme.primary,
        fillColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        textDirection: Directionality.of(context),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: points
              .map(
                (point) => Text(
                  point.label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.textDirection,
  });

  final List<TrendPoint> points;
  final Color lineColor;
  final Color fillColor;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    const horizontalPadding = 18.0;
    const topPadding = 18.0;
    const bottomPadding = 38.0;
    final chartWidth = size.width - horizontalPadding * 2;
    final chartHeight = size.height - topPadding - bottomPadding;
    final maxValue = points.map((e) => e.value).reduce(math.max);
    final minValue = points.map((e) => e.value).reduce(math.min);
    final range = math.max(maxValue - minValue, 1);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.10)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final dy = topPadding + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(horizontalPadding, dy),
        Offset(size.width - horizontalPadding, dy),
        gridPaint,
      );
    }

    final linePath = Path();
    final fillPath = Path();

    for (int index = 0; index < points.length; index++) {
      final point = points[index];
      final dx = points.length == 1
          ? size.width / 2
          : horizontalPadding + (chartWidth / (points.length - 1)) * index;
      final normalized = (point.value - minValue) / range;
      final dy = topPadding + chartHeight - (normalized * chartHeight);
      final offset = Offset(dx, dy);

      if (index == 0) {
        linePath.moveTo(offset.dx, offset.dy);
        fillPath.moveTo(offset.dx, size.height - bottomPadding);
        fillPath.lineTo(offset.dx, offset.dy);
      } else {
        linePath.lineTo(offset.dx, offset.dy);
        fillPath.lineTo(offset.dx, offset.dy);
      }

      canvas.drawCircle(offset, 4.5, Paint()..color = lineColor);
    }

    fillPath.lineTo(
        size.width - horizontalPadding, size.height - bottomPadding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.textDirection != textDirection;
  }
}

String _periodLabel(ReportPeriod period) {
  switch (period) {
    case ReportPeriod.weekly:
      return 'Weekly';
    case ReportPeriod.monthly:
      return 'Monthly';
    case ReportPeriod.quarterly:
      return 'Quarterly';
    case ReportPeriod.yearly:
      return 'Yearly';
  }
}

Color _severityColor(ReportSeverity severity) {
  switch (severity) {
    case ReportSeverity.good:
      return Colors.green;
    case ReportSeverity.warning:
      return Colors.orangeAccent;
    case ReportSeverity.critical:
      return Colors.redAccent;
  }
}

String _jobLabel(ExportJobStatus status) {
  switch (status) {
    case ExportJobStatus.ready:
      return 'Ready';
    case ExportJobStatus.processing:
      return 'Processing';
    case ExportJobStatus.completed:
      return 'Completed';
  }
}
