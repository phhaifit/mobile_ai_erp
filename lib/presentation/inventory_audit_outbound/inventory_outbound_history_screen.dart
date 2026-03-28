import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/inventory_audit_outbound/outbound_record.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/inventory_shared_widgets.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/store/inventory_audit_outbound_store.dart';

class InventoryOutboundHistoryScreen extends StatefulWidget {
  const InventoryOutboundHistoryScreen({super.key, this.store});

  final InventoryAuditOutboundStore? store;

  @override
  State<InventoryOutboundHistoryScreen> createState() =>
      _InventoryOutboundHistoryScreenState();
}

class _InventoryOutboundHistoryScreenState extends State<InventoryOutboundHistoryScreen> {
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
      appBar: AppBar(title: const Text('Outbound History')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Observer(
            builder: (_) {
              if (_store.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_store.outboundRecords.isEmpty) {
                return const Center(child: Text('No outbound records yet.'));
              }

              final isDesktop = constraints.maxWidth >= 600;
              final records = _store.outboundRecords.toList(growable: false);
              if (isDesktop) {
                return _OutboundHistoryDesktop(records: records);
              }
              return _OutboundHistoryMobile(records: records);
            },
          );
        },
      ),
    );
  }
}

class _OutboundHistoryDesktop extends StatelessWidget {
  const _OutboundHistoryDesktop({required this.records});

  final List<OutboundRecord> records;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InventorySectionCard(
        title: 'All Outbound Records',
        child: SingleChildScrollView(
          key: const Key('outbound_history_desktop_table'),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Date/Time', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Warehouse', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text('Note', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              ...records.map(
                (record) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(formatDateTime(record.createdAt))),
                      Expanded(flex: 2, child: Text(record.warehouseName)),
                      Expanded(flex: 2, child: Text(record.productName)),
                      Expanded(flex: 1, child: Text('${record.quantity}')),
                      Expanded(flex: 3, child: Text(record.note?.trim().isNotEmpty == true ? record.note! : '-')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutboundHistoryMobile extends StatelessWidget {
  const _OutboundHistoryMobile({required this.records});

  final List<OutboundRecord> records;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('outbound_history_mobile_cards'),
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final record = records[index];
        return InventorySectionCard(
          title: record.productName,
          trailing: Text(formatDateTime(record.createdAt)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Warehouse: ${record.warehouseName}'),
              Text('Quantity: ${record.quantity}'),
              Text('Note: ${record.note?.trim().isNotEmpty == true ? record.note! : '-'}'),
            ],
          ),
        );
      },
    );
  }
}
