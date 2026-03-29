import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_line.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/audit_record.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_shared_widgets.dart';
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

              if (_store.auditRecords.isEmpty) {
                return const Center(child: Text('No audit records yet.'));
              }

              final isDesktop = constraints.maxWidth >= 600;
              if (isDesktop) {
                return _DesktopSummary(
                  records: _store.auditRecords.toList(growable: false),
                );
              }
              return _MobileSummary(
                records: _store.auditRecords.toList(growable: false),
              );
            },
          );
        },
      ),
    );
  }
}

class _DesktopSummary extends StatelessWidget {
  const _DesktopSummary({required this.records});

  final List<AuditRecord> records;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InventorySectionCard(
        title: 'Audit Records',
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
                      Text(
                        '${record.warehouseName} - ${formatDateTime(record.createdAt)} (Mismatch: ${record.totalMismatchCount})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        color: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
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
                                'Physical',
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
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}

class _DesktopLineRow extends StatelessWidget {
  const _DesktopLineRow({required this.line});

  final AuditLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: line.discrepancy == 0 ? null : Colors.red.withValues(alpha: 0.08),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(line.productName)),
          Expanded(flex: 2, child: Text('${line.systemQty} ${line.unit}')),
          Expanded(flex: 2, child: Text('${line.physicalQty} ${line.unit}')),
          Expanded(flex: 2, child: DiscrepancyBadge(discrepancy: line.discrepancy)),
        ],
      ),
    );
  }
}

class _MobileSummary extends StatelessWidget {
  const _MobileSummary({required this.records});

  final List<AuditRecord> records;

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
          title: record.warehouseName,
          trailing: Text(formatDateTime(record.createdAt)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mismatch lines: ${record.totalMismatchCount}'),
              const SizedBox(height: 8),
              ...record.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(line.productName)),
                      DiscrepancyBadge(discrepancy: line.discrepancy),
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
