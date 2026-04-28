import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_item.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/fulfillment_shipment.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/order_print_label.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/order_tracking.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';

class FulfillmentDetailScreen extends StatefulWidget {
  const FulfillmentDetailScreen({super.key});

  @override
  State<FulfillmentDetailScreen> createState() => _FulfillmentDetailScreenState();
}

class _FulfillmentDetailScreenState extends State<FulfillmentDetailScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
  late ReactionDisposer _errorDisposer;
  
  List<ShipmentTrackingInfo> _shipmentBatches = const [];
  bool _loadingShipments = false;

  @override
  void initState() {
    super.initState();
    _errorDisposer = reaction(
      (_) => _store.errorStore.errorMessage,
      (String message) {
        if (message.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
    
    _loadShipments();
  }

  Future<void> _loadShipments() async {
    final order = _store.selectedOrder;
    if (order == null) return;
    setState(() => _loadingShipments = true);
    final shipments = await _store.getOrderShipmentBatches(order.id);
    if (mounted) {
      setState(() {
        _shipmentBatches = shipments;
        _loadingShipments = false;
      });
    }
  }

  @override
  void dispose() {
    _errorDisposer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final order = _store.selectedOrder;
        if (_store.isLoadingDetail && order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Detail')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Detail')),
            body: const Center(child: Text('Order not found')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: Text(order.code),
            actions: [
              IconButton(
                icon: const Icon(Icons.track_changes),
                tooltip: 'History & Tracking',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FulfillmentTrackingScreen()),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                _buildShipmentBatchesSection(order),
                _buildActionButtons(order),
                _buildItemsSection(order),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderHeader(FulfillmentOrder order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              _buildStatusChip(order.status),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person_outline, 'Customer', order.customerName),
          if (order.customerPhone != null)
            _buildInfoRow(Icons.phone_outlined, 'Phone', order.customerPhone!),
          if (order.shippingAddress != null)
            _buildInfoRow(Icons.location_on_outlined, 'Address', order.shippingAddress!),
          _buildInfoRow(Icons.attach_money, 'Total Price', _currencyFormat.format(order.totalAmount)),
          _buildInfoRow(Icons.calendar_today, 'Created At', DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)),
        ],
      ),
    );
  }

  Widget _buildShipmentBatchesSection(FulfillmentOrder order) {
    if (_shipmentBatches.isEmpty && !_loadingShipments) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipment Batches',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_loadingShipments)
            const Center(child: LinearProgressIndicator())
          else
            ..._shipmentBatches.map((s) => Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                dense: true,
                title: Text('Batch #${s.shipmentNumber} • ${s.trackingCode}'),
                subtitle: Text('Status: ${s.status}'),
                trailing: IconButton(
                  icon: const Icon(Icons.print, color: Colors.blue),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => OrderPrintLabelScreen(shipment: s)),
                  ),
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(FulfillmentOrder order) {
    final isActiveShipping = order.status.isActiveShippingPhase;
    final isFulfillmentPhase = order.status == FulfillmentStatus.confirmed ||
        order.status == FulfillmentStatus.packing ||
        isActiveShipping;

    // Nothing to show for terminal statuses.
    if (order.status.isTerminal) return const SizedBox.shrink();

    final nextStatus = _getNextStatus(order.status);
    
    // Logic: If we are in a phase that requires the Fulfillment Manager (Manifest), 
    // we hide the manual "Mark as..." button to prevent confusion.
    // The user should go through the "Start Fulfillment" flow instead.
    final showManualNextButton = nextStatus != null && 
        order.status != FulfillmentStatus.confirmed && 
        order.status != FulfillmentStatus.packing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isFulfillmentPhase) ...[
            _buildFulfillmentPrompt(order),
            const SizedBox(height: 12),
          ],
          if (showManualNextButton)
            ElevatedButton.icon(
              onPressed: () => _store.updateStatus(order.id, nextStatus),
              icon: Icon(_getStatusIcon(nextStatus)),
              label: Text('Mark as ${nextStatus.displayName}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: nextStatus == FulfillmentStatus.success ? Colors.green.shade600 : Colors.indigo.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          if (!order.status.isActiveShippingPhase && order.status != FulfillmentStatus.delivered) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _confirmCancelOrder(order.id),
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('Cancel Order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFulfillmentPrompt(FulfillmentOrder order) {
    final isShipping = order.status.isActiveShippingPhase;
    final accentColor = isShipping ? Colors.indigo : Colors.blue.shade600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            isShipping ? Icons.local_shipping_outlined : Icons.inventory_2_outlined,
                            color: accentColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isShipping ? 'Active Shipments' : 'Packing Required',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  isShipping 
                                      ? 'Manage batches or create more.' 
                                      : 'Start allocating items for delivery.',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const FulfillmentShipmentScreen()),
                            );
                            _loadShipments();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isShipping ? 'OPEN MANIFEST' : 'START FULFILLMENT',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildItemsSection(FulfillmentOrder order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${order.items.length})',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: ListTile(
              title: Text(item.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text('SKU: ${item.sku} • Qty: ${item.quantity}', style: const TextStyle(fontSize: 12)),
              trailing: Text(_currencyFormat.format(item.totalPrice), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          )),
        ],
      ),
    );
  }

  void _confirmCancelOrder(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure? This will stop the fulfillment process.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _store.updateStatus(orderId, FulfillmentStatus.cancelled);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  FulfillmentStatus? _getNextStatus(FulfillmentStatus current) {
    switch (current) {
      case FulfillmentStatus.newOrder: return FulfillmentStatus.pending;
      case FulfillmentStatus.pending: return FulfillmentStatus.confirmed;
      case FulfillmentStatus.confirmed: return FulfillmentStatus.packing;
      case FulfillmentStatus.packing: return FulfillmentStatus.shipping;
      case FulfillmentStatus.delivered: return FulfillmentStatus.success;
      default: return null;
    }
  }

  IconData _getStatusIcon(FulfillmentStatus status) {
    switch (status) {
      case FulfillmentStatus.pending: return Icons.hourglass_top;
      case FulfillmentStatus.confirmed: return Icons.check_circle;
      case FulfillmentStatus.packing: return Icons.inventory;
      case FulfillmentStatus.shipping: return Icons.local_shipping;
      case FulfillmentStatus.success: return Icons.verified;
      default: return Icons.arrow_forward;
    }
  }

  Widget _buildStatusChip(FulfillmentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: _getStatusColor(status), fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(FulfillmentStatus status) {
    switch (status) {
      case FulfillmentStatus.newOrder: return Colors.grey;
      case FulfillmentStatus.pending: return Colors.orange;
      case FulfillmentStatus.confirmed: return Colors.blue;
      case FulfillmentStatus.packing: return Colors.deepOrange;
      case FulfillmentStatus.shipping: return Colors.indigo;
      case FulfillmentStatus.success: return Colors.green;
      case FulfillmentStatus.cancelled: return Colors.red;
      default: return Colors.grey;
    }
  }
}
