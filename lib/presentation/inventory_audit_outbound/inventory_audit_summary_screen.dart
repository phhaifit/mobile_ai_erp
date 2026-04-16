import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_shared_widgets.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/models/inventory_workflow_view_models.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/store/inventory_audit_outbound_store.dart';

class InventoryAuditSummaryScreen extends StatefulWidget {
  const InventoryAuditSummaryScreen({super.key, this.store});

  final InventoryAuditOutboundStore? store;

  @override
  State<InventoryAuditSummaryScreen> createState() =>
      _InventoryAuditSummaryScreenState();
}

class _InventoryAuditSummaryScreenState extends State<InventoryAuditSummaryScreen> {
  late final InventoryAuditOutboundStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? getIt<InventoryAuditOutboundStore>();
    _store.loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Audit Summary')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Observer(
            builder: (_) {
              if (_store.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final sessions = _store.stocktakeHistory.toList(growable: true);
              final active = _store.activeSession;

              if (active != null &&
                  active.status == StocktakeSessionStatus.reconciled &&
                  sessions.every((session) => session.id != active.id)) {
                sessions.insert(0, active);
              }

              if (sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('No reconciliation results yet.'),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _store.loadInitialData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final isDesktop = constraints.maxWidth >= 600;
              if (isDesktop) {
                return _DesktopSummary(records: sessions);
              }
              return _MobileSummary(records: sessions);
            },
          );
        },
      ),
    );
  }
}

class _DesktopSummary extends StatelessWidget {
  const _DesktopSummary({required this.records});

  final List<StocktakeSessionViewModel> records;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InventorySectionCard(
        title: 'Reconciliation Sessions',
        child: SingleChildScrollView(
          key: const Key('audit_summary_desktop_table'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: records
                .map(
                  (record) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${record.code} | ${record.warehouseName} | ${formatDateTime(record.openedAt)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          WorkflowStatusBadge.stocktake(status: record.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mismatch lines: ${record.mismatchCount} | Total discrepancy: ${record.totalAbsoluteDiscrepancy} | Server: ${record.serverCalculated ? 'Yes' : 'No'}',
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withValues(alpha: 0.3),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Product',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'System',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Counted',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Discrepancy',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...record.lines.map((line) => _DesktopLineRow(line: line)),
                      const Divider(height: 20),
                    ],
                  ),
                )
                .toList(growable: true),
          ),
        ),
      ),
    );
  }
}

class _DesktopLineRow extends StatelessWidget {
  const _DesktopLineRow({required this.line});

  final StocktakeLineViewModel line;

  @override
  Widget build(BuildContext context) {
    final discrepancy = line.discrepancy ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: discrepancy == 0 ? null : Colors.red.withValues(alpha: 0.08),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(line.productName)),
          Expanded(flex: 2, child: Text('${line.systemQty} ${line.unit}')),
          Expanded(flex: 2, child: Text('${line.countedQty ?? '-'} ${line.unit}')),
          Expanded(flex: 2, child: DiscrepancyBadge(discrepancy: discrepancy)),
        ],
      ),
    );
  }
}

class _MobileSummary extends StatelessWidget {
  const _MobileSummary({required this.records});

  final List<StocktakeSessionViewModel> records;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('audit_summary_mobile_cards'),
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final record = records[index];
        return InventorySectionCard(
          title: record.code,
          trailing: WorkflowStatusBadge.stocktake(status: record.status),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(record.warehouseName),
              Text('Opened: ${formatDateTime(record.openedAt)}'),
              Text('Mismatch lines: ${record.mismatchCount}'),
              Text('Total discrepancy: ${record.totalAbsoluteDiscrepancy}'),
              const SizedBox(height: 8),
              ...record.lines.take(4).map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(line.productName)),
                          DiscrepancyBadge(discrepancy: line.discrepancy ?? 0),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

