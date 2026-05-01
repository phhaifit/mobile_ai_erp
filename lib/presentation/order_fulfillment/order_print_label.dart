import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';
import 'package:intl/intl.dart';

class OrderPrintLabelScreen extends StatefulWidget {
  final ShipmentTrackingInfo shipment;

  const OrderPrintLabelScreen({super.key, required this.shipment});

  @override
  State<OrderPrintLabelScreen> createState() => _OrderPrintLabelScreenState();
}

class _OrderPrintLabelScreenState extends State<OrderPrintLabelScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();
  List<ShipmentLabelArtifact> _labelArtifacts = const [];
  List<ShipmentPrintJob> _printJobs = const [];
  bool _loadingData = false;
  bool _submittingPrint = false;

  @override
  void initState() {
    super.initState();
    _loadPrintData();
  }

  Future<void> _loadPrintData() async {
    final order = _store.selectedOrder;
    if (order == null || _loadingData) return;
    setState(() => _loadingData = true);
    final labels = await _store.getShipmentLabelArtifacts(order.id, widget.shipment.id);
    final jobs = await _store.getShipmentPrintJobs(order.id, widget.shipment.id);
    if (!mounted) return;
    setState(() {
      _labelArtifacts = labels;
      _printJobs = jobs;
      _loadingData = false;
    });
  }

  Future<void> _handlePrint() async {
    final order = _store.selectedOrder;
    if (order == null || _submittingPrint) return;
    setState(() => _submittingPrint = true);
    
    final startedAt = DateTime.now();
    final createdJob = await _store.createShipmentPrintJob(
      order.id,
      widget.shipment.id,
      artifactType: 'shipping_label',
      format: 'pdf',
      printerName: 'Mobile Preview Printer',
      printerCode: 'MOBILE-PREVIEW',
      copies: 1,
      metadata: {'source': 'mobile_ai_erp', 'screen': 'print_label_dedicated'},
    );

    if (createdJob != null && mounted) {
      await _store.createShipmentPrintAttempt(
        order.id,
        widget.shipment.id,
        createdJob.id,
        status: 'succeeded',
        spoolJobId: 'mobile-${DateTime.now().millisecondsSinceEpoch}',
        durationMs: DateTime.now().difference(startedAt).inMilliseconds,
        printerResponse: {'channel': 'mobile-preview', 'message': 'Printed from dedicated screen'},
      );
      await _loadPrintData();
    }
    
    if (mounted) setState(() => _submittingPrint = false);
  }

  @override
  Widget build(BuildContext context) {
    final order = _store.selectedOrder;
    return Scaffold(
      appBar: AppBar(title: const Text('Print Shipping Label')),
      body: order == null 
        ? const Center(child: Text('Order not found'))
        : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildShipmentBanner(),
                      const SizedBox(height: 24),
                      _buildLabelPreview(order),
                      const SizedBox(height: 24),
                      _buildPrintHistory(),
                    ],
                  ),
                ),
              ),
              _buildBottomAction(),
            ],
          ),
    );
  }

  Widget _buildShipmentBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.qr_code_2, size: 40, color: Colors.blue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Batch #${widget.shipment.shipmentNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.shipment.trackingCode, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabelPreview(dynamic order) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black,
            width: double.infinity,
            child: const Text('SHIPPING LABEL', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labelRow('FROM:', 'AI ERP Warehouse\nHo Chi Minh City'),
                const Divider(height: 30),
                _labelRow('TO:', '${order.customerName}\n${order.shippingAddress}'),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    height: 60,
                    width: 200,
                    color: Colors.grey.shade200,
                    child: const Center(child: Text('[ BARCODE ]')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPrintHistory() {
    if (_printJobs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Print Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._printJobs.take(3).map((job) => ListTile(
          dense: true,
          leading: const Icon(Icons.print_outlined, size: 16),
          title: Text('Printed at ${DateFormat('HH:mm').format(job.queuedAt)}'),
          trailing: Text(job.status.toUpperCase(), style: const TextStyle(fontSize: 10)),
        )),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -5), blurRadius: 10)],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _submittingPrint ? null : _handlePrint,
            icon: const Icon(Icons.print),
            label: Text(_submittingPrint ? 'PRINTING...' : 'PRINT NOW'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
