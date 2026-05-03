import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/dashboard/dashboard_entities.dart';
import 'package:mobile_ai_erp/presentation/dashboard/store/dashboard_store.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.store});

  final DashboardStore? store;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? getIt<DashboardStore>();
    _store.loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Dashboard'),
      ),
      body: Observer(
        builder: (_) {
          if (_store.errorMessage.isNotEmpty && !_store.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 42),
                    const SizedBox(height: 12),
                    Text(_store.errorMessage),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _store.loadDashboard,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_store.isLoading && !_store.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              return RefreshIndicator(
                onRefresh: _store.loadDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: isDesktop
                      ? _buildDesktopLayout(context)
                      : _buildMobileLayout(context),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHealthOverview(),
        const SizedBox(height: 12),
        _buildPendingTasks(),
        const SizedBox(height: 12),
        _buildSalesChart(),
        const SizedBox(height: 12),
        _buildInsightsFeed(),
        const SizedBox(height: 12),
        _buildQuickNavigation(),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHealthOverview(),
                  const SizedBox(height: 12),
                  _buildSalesChart(),
                  const SizedBox(height: 12),
                  _buildInsightsFeed(),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildPendingTasks(),
                  const SizedBox(height: 12),
                  _buildQuickNavigation(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSwitcher() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: DashboardPeriod.values.map((period) {
        final isSelected = _store.period == period;
        return ChoiceChip(
          label: Text(_periodLabel(period)),
          selected: isSelected,
          onSelected: (_) => _store.setPeriod(period),
        );
      }).toList(growable: false),
    );
  }

  Widget _buildHealthOverview() {
    return _DashboardSectionCard(
      title: 'Business Health Overview',
      subtitle: 'Snapshot of key operational metrics',
      icon: Icons.monitor_heart_outlined,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _store.kpis.map((kpi) {
          return _KpiCard(kpi: kpi);
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildPendingTasks() {
    return _DashboardSectionCard(
      title: 'Pending Tasks',
      subtitle:
          '${_store.totalPending} open tasks • ${_store.criticalPendingCount} critical',
      icon: Icons.task_alt_outlined,
      child: Column(
        children: _store.pendingTasks.map((task) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: _priorityColor(task.priority).withValues(alpha: 0.18),
              child: Icon(
                Icons.priority_high,
                size: 16,
                color: _priorityColor(task.priority),
              ),
            ),
            title: Text(task.title),
            subtitle: Text('${task.module} • due ${_relativeDue(task.dueAt)}'),
            trailing: task.isOverdue
                ? const Chip(label: Text('Overdue'))
                : const SizedBox.shrink(),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildSalesChart() {
    return _DashboardSectionCard(
      title: 'Real-Time Sales',
      subtitle: 'Trend preview for ${_periodLabel(_store.period).toLowerCase()}',
      icon: Icons.show_chart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodSwitcher(),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: _store.salesSeries.isEmpty
                ? const Center(child: Text('No sales data'))
                : _SalesTrendChart(
                    points: _store.salesSeries.toList(growable: false),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsFeed() {
    return _DashboardSectionCard(
      title: 'Smart Insights Feed',
      subtitle: 'Read-only operational highlights',
      icon: Icons.auto_awesome_outlined,
      child: Column(
        children: _store.insights.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              tileColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(
                _insightIcon(item.category),
                color: _severityColor(item.severity),
              ),
              title: Text(item.title),
              subtitle: Text(item.summary),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildQuickNavigation() {
    return _DashboardSectionCard(
      title: 'Quick Navigation',
      subtitle: 'Jump to core modules',
      icon: Icons.flash_on_outlined,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _store.quickNavItems.map((item) {
          return ActionChip(
            avatar: Icon(_iconForTarget(item.target)),
            label: Text(item.badgeCount == null
                ? item.label
                : '${item.label} (${item.badgeCount})'),
            onPressed: () {
              Navigator.of(context).pushNamed(_routeForTarget(item.target));
            },
          );
        }).toList(growable: false),
      ),
    );
  }

  Color _priorityColor(DashboardTaskPriority priority) {
    switch (priority) {
      case DashboardTaskPriority.low:
        return Colors.green;
      case DashboardTaskPriority.medium:
        return Colors.amber.shade800;
      case DashboardTaskPriority.high:
        return Colors.deepOrange;
      case DashboardTaskPriority.critical:
        return Colors.red;
    }
  }

  Color _severityColor(DashboardInsightSeverity severity) {
    switch (severity) {
      case DashboardInsightSeverity.info:
        return Colors.blue;
      case DashboardInsightSeverity.warning:
        return Colors.orange;
      case DashboardInsightSeverity.critical:
        return Colors.red;
    }
  }

  IconData _insightIcon(DashboardInsightCategory category) {
    switch (category) {
      case DashboardInsightCategory.opportunity:
        return Icons.trending_up;
      case DashboardInsightCategory.risk:
        return Icons.warning_amber_outlined;
      case DashboardInsightCategory.highlight:
        return Icons.lightbulb_outline;
    }
  }

  String _periodLabel(DashboardPeriod period) {
    switch (period) {
      case DashboardPeriod.daily:
        return 'Daily';
      case DashboardPeriod.weekly:
        return 'Weekly';
      case DashboardPeriod.monthly:
        return 'Monthly';
    }
  }

  String _relativeDue(DateTime dueAt) {
    final diff = dueAt.difference(DateTime.now());
    if (diff.isNegative) {
      return 'past due';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    }
    return '${diff.inHours}h';
  }

  String _routeForTarget(DashboardQuickTarget target) {
    switch (target) {
      case DashboardQuickTarget.products:
        return Routes.productManagementList;
      case DashboardQuickTarget.stockOperations:
        return Routes.stockOperations;
      case DashboardQuickTarget.orders:
        return Routes.orderTracking;
      case DashboardQuickTarget.suppliers:
        return Routes.suppliers;
      case DashboardQuickTarget.reports:
        return Routes.reports;
    }
  }

  IconData _iconForTarget(DashboardQuickTarget target) {
    switch (target) {
      case DashboardQuickTarget.products:
        return Icons.inventory_2_outlined;
      case DashboardQuickTarget.stockOperations:
        return Icons.warehouse_outlined;
      case DashboardQuickTarget.orders:
        return Icons.local_shipping_outlined;
      case DashboardQuickTarget.suppliers:
        return Icons.store_outlined;
      case DashboardQuickTarget.reports:
        return Icons.insights_outlined;
    }
  }
}

class _DashboardSectionCard extends StatelessWidget {
  const _DashboardSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi});

  final DashboardKpi kpi;

  @override
  Widget build(BuildContext context) {
    final isUp = kpi.trend == DashboardTrendDirection.up;
    final color = isUp ? Colors.green : Colors.red;

    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kpi.label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            kpi.value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isUp ? Icons.trending_up : Icons.trending_down,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                '${kpi.deltaPercent.toStringAsFixed(1)}%',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalesTrendChart extends StatelessWidget {
  const _SalesTrendChart({required this.points});

  final List<SalesDataPoint> points;

  @override
  Widget build(BuildContext context) {
    final labels = points.map((point) => point.label).toList(growable: false);

    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _SalesTrendPainter(
              points: points,
              lineColor: Theme.of(context).colorScheme.primary,
              fillColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.15),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: labels
              .map(
                (label) => Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _SalesTrendPainter extends CustomPainter {
  _SalesTrendPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
  });

  final List<SalesDataPoint> points;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    const leftPadding = 14.0;
    const rightPadding = 14.0;
    const topPadding = 10.0;
    const bottomPadding = 20.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final values = points.map((point) => point.value);
    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final range = math.max(maxValue - minValue, 1);

    final linePath = Path();
    final fillPath = Path();

    for (int i = 0; i < points.length; i++) {
      final dx = points.length == 1
          ? size.width / 2
          : leftPadding + (chartWidth / (points.length - 1)) * i;
      final normalized = (points[i].value - minValue) / range;
      final dy = topPadding + chartHeight - (normalized * chartHeight);

      if (i == 0) {
        linePath.moveTo(dx, dy);
        fillPath.moveTo(dx, size.height - bottomPadding);
        fillPath.lineTo(dx, dy);
      } else {
        linePath.lineTo(dx, dy);
        fillPath.lineTo(dx, dy);
      }

      canvas.drawCircle(
        Offset(dx, dy),
        3.8,
        Paint()..color = lineColor,
      );
    }

    fillPath.lineTo(size.width - rightPadding, size.height - bottomPadding);
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SalesTrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}
