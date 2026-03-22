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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_outlined),
            SizedBox(width: 10),
            Text('Reports & Analytics'),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.06),
              colorScheme.surface,
              colorScheme.secondary.withValues(alpha: 0.35),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Observer(
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
                final isWide = constraints.maxWidth >= 1040;
                final isMedium = constraints.maxWidth >= 760;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ReportsHero(
                      filter: _store.selectedFilter,
                      insights: dashboard.insights,
                      onPeriodSelected: _store.changePeriod,
                    ),
                    const SizedBox(height: 18),
                    _KpiGrid(
                      kpis: dashboard.salesKpis,
                      columns: isWide ? 4 : (isMedium ? 2 : 1),
                    ),
                    const SizedBox(height: 18),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _ReportsSectionCard(
                              title: 'Sales analytics',
                              subtitle:
                                  'Trend line, channel mix, and revenue distribution.',
                              icon: Icons.show_chart_rounded,
                              child: _SalesAnalyticsSection(
                                dashboard: dashboard,
                                isWide: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _ReportsSectionCard(
                              title: 'Inventory reports',
                              subtitle:
                                  'Stock health, risk distribution, and replenishment priorities.',
                              icon: Icons.inventory_2_rounded,
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
                            'Trend line, channel mix, and revenue distribution.',
                        icon: Icons.show_chart_rounded,
                        child: _SalesAnalyticsSection(
                          dashboard: dashboard,
                          isWide: false,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ReportsSectionCard(
                        title: 'Inventory reports',
                        subtitle:
                            'Stock health, risk distribution, and replenishment priorities.',
                        icon: Icons.inventory_2_rounded,
                        child:
                            _InventorySection(items: dashboard.inventoryItems),
                      ),
                    ],
                    const SizedBox(height: 18),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _ReportsSectionCard(
                              title: 'Product performance',
                              subtitle:
                                  'Top sellers, low performers, and SKU revenue bars.',
                              icon: Icons.local_mall_outlined,
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
                              subtitle:
                                  'Revenue, costs, profit bridges, and margin signal.',
                              icon: Icons.account_balance_wallet_outlined,
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
                            'Top sellers, low performers, and SKU revenue bars.',
                        icon: Icons.local_mall_outlined,
                        child: _ProductPerformanceSection(
                          topProducts: dashboard.topProducts,
                          lowPerformers: dashboard.lowPerformers,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ReportsSectionCard(
                        title: 'Financial report (P&L)',
                        subtitle:
                            'Revenue, costs, profit bridges, and margin signal.',
                        icon: Icons.account_balance_wallet_outlined,
                        child:
                            _ProfitLossSection(rows: dashboard.profitAndLoss),
                      ),
                    ],
                    const SizedBox(height: 18),
                    _ReportsSectionCard(
                      title: 'Data export center',
                      subtitle:
                          'Curated report packs, export queue, and delivery formats.',
                      icon: Icons.download_for_offline_outlined,
                      trailing: FilledButton.icon(
                        onPressed: dashboard.exportJobs.isEmpty
                            ? null
                            : () => _store.exportJob(0),
                        icon: const Icon(Icons.ios_share_outlined),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.18),
            colorScheme.secondary.withValues(alpha: 0.70),
            colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.10),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 620,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.auto_graph_rounded,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Executive reporting cockpit',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Comprehensive reporting across sales, inventory, products, and financials.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${filter.label} • ${filter.dateRangeLabel}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _MetaChip(
                          icon: Icons.offline_bolt_outlined,
                          label: 'Offline mock data',
                        ),
                        _MetaChip(
                          icon: Icons.smart_toy_outlined,
                          label: 'AI insight assisted',
                        ),
                        _MetaChip(
                          icon: Icons.grid_view_rounded,
                          label: 'Web and mobile ready',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: () => onPeriodSelected(filter.period),
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Refresh AI summary'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => onPeriodSelected(ReportPeriod.quarterly),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Jump to quarter'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chipValues.map((period) {
              return ChoiceChip(
                avatar: Icon(
                  _periodIcon(period),
                  size: 18,
                  color: filter.period == period
                      ? colorScheme.onPrimary
                      : colorScheme.primary,
                ),
                label: Text(_periodLabel(period)),
                selected: filter.period == period,
                onSelected: (_) => onPeriodSelected(period),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
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
        childAspectRatio: columns >= 4 ? 1.55 : 1.35,
      ),
      itemBuilder: (context, index) {
        final item = kpis[index];
        final colorScheme = Theme.of(context).colorScheme;
        final trendColor =
            item.isPositive ? Colors.green.shade700 : Colors.orange;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _kpiIcon(item.title),
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              Text(
                item.value,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Row(
                children: [
                  Icon(
                    item.isPositive ? Icons.trending_up : Icons.trending_down,
                    color: trendColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
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
    required this.icon,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 20,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _SalesAnalyticsSection extends StatelessWidget {
  const _SalesAnalyticsSection({
    required this.dashboard,
    required this.isWide,
  });

  final ReportsDashboardData dashboard;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final breakdownValues = dashboard.salesBreakdowns
        .map((item) => _parseCompactCurrency(item.value))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _MetricPanel(
                  title: 'Sales trend',
                  subtitle: 'Demand movement across the selected period',
                  child: SizedBox(
                    height: 220,
                    child: _MockTrendChart(points: dashboard.trendPoints),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: _MetricPanel(
                  title: 'Channel mix',
                  subtitle: 'Revenue share by sales channel',
                  child: _DonutBreakdownChart(
                    labels:
                        dashboard.salesBreakdowns.map((e) => e.label).toList(),
                    values: breakdownValues,
                  ),
                ),
              ),
            ],
          )
        else ...[
          _MetricPanel(
            title: 'Sales trend',
            subtitle: 'Demand movement across the selected period',
            child: SizedBox(
              height: 220,
              child: _MockTrendChart(points: dashboard.trendPoints),
            ),
          ),
          const SizedBox(height: 14),
          _MetricPanel(
            title: 'Channel mix',
            subtitle: 'Revenue share by sales channel',
            child: _DonutBreakdownChart(
              labels: dashboard.salesBreakdowns.map((e) => e.label).toList(),
              values: breakdownValues,
            ),
          ),
        ],
        const SizedBox(height: 14),
        _MetricPanel(
          title: 'Channel performance',
          subtitle: 'Revenue and share contribution',
          child: Column(
            children: dashboard.salesBreakdowns.asMap().entries.map((entry) {
              final item = entry.value;
              final percent = _parsePercent(item.shareLabel);
              final color = _chartPalette[entry.key % _chartPalette.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        minHeight: 10,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
    final severityValues = [
      items
          .where((item) => item.severity == ReportSeverity.good)
          .length
          .toDouble(),
      items
          .where((item) => item.severity == ReportSeverity.warning)
          .length
          .toDouble(),
      items
          .where((item) => item.severity == ReportSeverity.critical)
          .length
          .toDouble(),
    ];

    return Column(
      children: [
        _MetricPanel(
          title: 'Stock risk profile',
          subtitle: 'How the inventory alerts are distributed',
          child: _HorizontalBarComparisonChart(
            labels: const ['Healthy', 'Warning', 'Critical'],
            values: severityValues,
            colors: const [
              Color(0xFF1E8E5A),
              Color(0xFFF9AB00),
              Color(0xFFD93025),
            ],
            compact: true,
          ),
        ),
        const SizedBox(height: 14),
        ...items.map(
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        _severityColor(item.severity).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _severityIcon(item.severity),
                    color: _severityColor(item.severity),
                  ),
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
        ),
      ],
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
    final topValues =
        topProducts.map((item) => _parseCompactCurrency(item.revenue)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricPanel(
          title: 'Top product revenue',
          subtitle: 'Horizontal bars make leader performance easy to compare',
          child: _HorizontalBarComparisonChart(
            labels: topProducts.map((e) => e.name).toList(),
            values: topValues,
            colors: const [
              Color(0xFF1666D3),
              Color(0xFF4C8DF6),
              Color(0xFF7DAAF8),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
    final color = positive ? Colors.green.shade700 : Colors.orange.shade700;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              positive ? Icons.workspace_premium : Icons.trending_down_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
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
    final summaryRows = <ProfitLossRow>[
      rows.firstWhere((row) => row.label == 'Revenue'),
      rows.firstWhere((row) => row.label == 'Gross profit'),
      rows.firstWhere((row) => row.label == 'Net profit'),
    ];

    return Column(
      children: [
        _MetricPanel(
          title: 'Profit bridge',
          subtitle: 'Column chart for revenue to profit compression',
          child: _VerticalBarChart(
            labels: summaryRows.map((e) => e.label).toList(),
            values: summaryRows
                .map((item) => _parseSignedCurrency(item.amount).abs())
                .toList(),
          ),
        ),
        const SizedBox(height: 14),
        ...rows.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  row.amount.startsWith('-')
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  color: row.amount.startsWith('-')
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
                  size: 18,
                ),
                const SizedBox(width: 10),
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
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _templateIcon(template.title),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(template.description),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: template.formats
                            .map(
                              (format) => Chip(
                                avatar: const Icon(
                                  Icons.file_present_outlined,
                                  size: 16,
                                ),
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
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _statusIcon(entry.value.status),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                    _StatusPill(status: entry.value.status),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => onRunExport(entry.key),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Run'),
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
    final colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: colorScheme.primary.withValues(alpha: 0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  insight.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(insight.summary),
          ],
        ),
      ),
    );
  }
}

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.surface.withValues(alpha: 0.85),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ExportJobStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        _jobLabel(status),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}

class _MockTrendChart extends StatelessWidget {
  const _MockTrendChart({required this.points});

  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _TrendChartPainter(
        points: points,
        lineColor: colorScheme.primary,
        fillColor: colorScheme.primary.withValues(alpha: 0.12),
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

class _DonutBreakdownChart extends StatelessWidget {
  const _DonutBreakdownChart({
    required this.labels,
    required this.values,
  });

  final List<String> labels;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final total = values.fold<double>(0, (sum, item) => sum + item);

    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: _DonutChartPainter(values: values),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Total', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    '\$${total.toStringAsFixed(1)}K',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: labels.asMap().entries.map((entry) {
              final index = entry.key;
              final value = values[index];
              final color = _chartPalette[index % _chartPalette.length];
              final share = total == 0 ? 0 : (value / total) * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(entry.value)),
                    Text('${share.toStringAsFixed(0)}%'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _HorizontalBarComparisonChart extends StatelessWidget {
  const _HorizontalBarComparisonChart({
    required this.labels,
    required this.values,
    required this.colors,
    this.compact = false,
  });

  final List<String> labels;
  final List<double> values;
  final List<Color> colors;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty ? 1.0 : values.reduce(math.max);

    return Column(
      children: labels.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final value = values[index];
        final color = colors[index % colors.length];
        return Padding(
          padding: EdgeInsets.only(bottom: compact ? 10 : 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    compact
                        ? value.toStringAsFixed(0)
                        : '\$${value.toStringAsFixed(1)}K',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: maxValue == 0 ? 0 : value / maxValue,
                  minHeight: compact ? 10 : 12,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.14),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _VerticalBarChart extends StatelessWidget {
  const _VerticalBarChart({
    required this.labels,
    required this.values,
  });

  final List<String> labels;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty ? 1.0 : values.reduce(math.max);
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: labels.asMap().entries.map((entry) {
          final index = entry.key;
          final value = values[index];
          final heightFactor = maxValue == 0 ? 0.0 : value / maxValue;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '\$${value.toStringAsFixed(0)}K',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: heightFactor.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              colors: [
                                _chartPalette[index % _chartPalette.length],
                                _chartPalette[index % _chartPalette.length]
                                    .withValues(alpha: 0.55),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
  });

  final List<TrendPoint> points;
  final Color lineColor;
  final Color fillColor;

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
      size.width - horizontalPadding,
      size.height - bottomPadding,
    );
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, item) => sum + item);
    if (total <= 0) {
      return;
    }

    const strokeWidth = 18.0;
    final rect = Offset.zero & size;
    final adjustedRect = rect.deflate(strokeWidth / 2);
    var startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * math.pi * 2;
      final paint = Paint()
        ..color = _chartPalette[i % _chartPalette.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(adjustedRect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.values != values;
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

IconData _periodIcon(ReportPeriod period) {
  switch (period) {
    case ReportPeriod.weekly:
      return Icons.view_week_outlined;
    case ReportPeriod.monthly:
      return Icons.calendar_view_month_outlined;
    case ReportPeriod.quarterly:
      return Icons.date_range_outlined;
    case ReportPeriod.yearly:
      return Icons.event_available_outlined;
  }
}

IconData _kpiIcon(String title) {
  switch (title) {
    case 'Net sales':
      return Icons.payments_outlined;
    case 'Orders fulfilled':
      return Icons.local_shipping_outlined;
    case 'Gross margin':
      return Icons.pie_chart_outline_rounded;
    case 'Returns':
      return Icons.assignment_return_outlined;
    default:
      return Icons.analytics_outlined;
  }
}

IconData _severityIcon(ReportSeverity severity) {
  switch (severity) {
    case ReportSeverity.good:
      return Icons.verified_outlined;
    case ReportSeverity.warning:
      return Icons.warning_amber_rounded;
    case ReportSeverity.critical:
      return Icons.error_outline_rounded;
  }
}

Color _severityColor(ReportSeverity severity) {
  switch (severity) {
    case ReportSeverity.good:
      return const Color(0xFF1E8E5A);
    case ReportSeverity.warning:
      return const Color(0xFFF9AB00);
    case ReportSeverity.critical:
      return const Color(0xFFD93025);
  }
}

IconData _templateIcon(String title) {
  if (title.contains('Executive')) {
    return Icons.badge_outlined;
  }
  if (title.contains('Inventory')) {
    return Icons.inventory_outlined;
  }
  return Icons.table_chart_outlined;
}

IconData _statusIcon(ExportJobStatus status) {
  switch (status) {
    case ExportJobStatus.ready:
      return Icons.check_circle_outline;
    case ExportJobStatus.processing:
      return Icons.sync;
    case ExportJobStatus.completed:
      return Icons.task_alt_outlined;
  }
}

Color _statusColor(ExportJobStatus status) {
  switch (status) {
    case ExportJobStatus.ready:
      return const Color(0xFF1666D3);
    case ExportJobStatus.processing:
      return const Color(0xFF5F8DFF);
    case ExportJobStatus.completed:
      return const Color(0xFF1E8E5A);
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

double _parseCompactCurrency(String value) {
  final normalized = value.replaceAll('\$', '').replaceAll(',', '').trim();
  if (normalized.endsWith('K')) {
    return double.tryParse(normalized.substring(0, normalized.length - 1)) ?? 0;
  }
  return (double.tryParse(normalized) ?? 0) / 1000;
}

double _parsePercent(String label) {
  final match = RegExp(r'(\d+)').firstMatch(label);
  return double.tryParse(match?.group(1) ?? '0') ?? 0;
}

double _parseSignedCurrency(String value) {
  final normalized = value.replaceAll('\$', '').replaceAll(',', '').trim();
  return double.tryParse(normalized) ?? 0;
}

const List<Color> _chartPalette = [
  Color(0xFF1666D3),
  Color(0xFF4C8DF6),
  Color(0xFF7DAAF8),
  Color(0xFF9BD4FF),
];
