import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_item.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';

class FulfillmentDetailScreen extends StatefulWidget {
  const FulfillmentDetailScreen({super.key});

  @override
  State<FulfillmentDetailScreen> createState() =>
      _FulfillmentDetailScreenState();
}

class _FulfillmentDetailScreenState extends State<FulfillmentDetailScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
  late ReactionDisposer _errorDisposer;
  bool _hasCarrierShipment = false;
  bool _isCheckingCarrierShipment = false;
  String? _shipmentCheckedOrderId;

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

        // Only check for carrier shipment when the order is actively being shipped.
        if (order.status.isActiveShippingPhase &&
            _shipmentCheckedOrderId != order.id &&
            !_isCheckingCarrierShipment) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadCarrierShipmentState(order.id);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(order.code),
            actions: [
              IconButton(
                icon: const Icon(Icons.timeline),
                tooltip: 'Track Order',
                onPressed: () => Navigator.of(context).pushNamed(
                  Routes.fulfillmentTracking,
                  arguments: order.id,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.inventory_2_outlined),
                tooltip: 'Packaging',
                onPressed: () => Navigator.of(context).pushNamed(
                  Routes.fulfillmentPackaging,
                  arguments: order.id,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.print_outlined),
                tooltip: 'Print Label',
                onPressed: () => Navigator.of(context).pushNamed(
                  Routes.fulfillmentPrintLabel,
                  arguments: order.id,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderHeader(order),
                const Divider(height: 1),
                _buildItemsSection(order),
                const Divider(height: 1),
                _buildActionButtons(order),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderHeader(FulfillmentOrder order) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              _buildStatusChip(order.status),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person_outline, 'Customer', order.customerName),
          if (order.customerPhone != null)
            _buildInfoRow(Icons.phone_outlined, 'Phone', order.customerPhone!),
          if (order.shippingAddress != null)
            _buildInfoRow(
                Icons.location_on_outlined, 'Address', order.shippingAddress!),
          _buildInfoRow(Icons.storefront, 'Source', order.source),
          _buildInfoRow(Icons.payment, 'Payment', order.paymentStatus),
          _buildInfoRow(Icons.calendar_today, 'Created',
              DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)),
          _buildInfoRow(Icons.attach_money, 'Total',
              _currencyFormat.format(order.totalAmount)),
          if (order.notes != null && order.notes!.isNotEmpty)
            _buildInfoRow(Icons.note_outlined, 'Notes', order.notes!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).hintColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
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
            'Items (${order.items.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => _buildItemTile(item)),
        ],
      ),
    );
  }

  Widget _buildItemTile(FulfillmentItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  _currencyFormat.format(item.totalPrice),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'SKU: ${item.sku}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Qty: ${item.quantity}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Text(
                  '× ${_currencyFormat.format(item.unitPrice)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(FulfillmentOrder order) {
    // Active shipping phase: carrier (GHN) drives transitions via webhook — no manual buttons.
    final isActiveShipping = order.status.isActiveShippingPhase;
    final hasResolvedCarrierState =
        _shipmentCheckedOrderId == order.id && !_isCheckingCarrierShipment;
    final isAwaitingCarrierCheck = isActiveShipping && !hasResolvedCarrierState;
    final isCarrierManaged = _hasCarrierShipment && isActiveShipping;
    final canUseManualStatusActions = !isAwaitingCarrierCheck && !isCarrierManaged;

    // Nothing to show for terminal statuses.
    if (order.status.isTerminal) return const SizedBox.shrink();

    final nextStatus = _getNextStatus(order.status);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isAwaitingCarrierCheck)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Checking carrier shipment status... please wait.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (isActiveShipping && !isCarrierManaged)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Create shipment batches from Print Label. Delivered status is synchronized from carrier tracking.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (isCarrierManaged)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Carrier shipment is linked. Delivery status is synchronized from GHN tracking/webhook.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (nextStatus != null && canUseManualStatusActions)
            ElevatedButton.icon(
              onPressed: () => _store.updateStatus(order.id, nextStatus),
              icon: Icon(_getStatusIcon(nextStatus)),
              label: Text('Mark as ${nextStatus.displayName}'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          // Cancel is available for pre-shipping statuses only.
          if (!order.status.isTerminal &&
              !isActiveShipping &&
              order.status != FulfillmentStatus.delivered &&
              order.status != FulfillmentStatus.success &&
              canUseManualStatusActions) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _confirmCancelOrder(order.id),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Order'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _loadCarrierShipmentState(String orderId) async {
    if (_isCheckingCarrierShipment) {
      return;
    }

    setState(() {
      _isCheckingCarrierShipment = true;
      _shipmentCheckedOrderId = orderId;
    });

    final shipments = await _store.getOrderShipmentBatches(
      orderId,
      refresh: false,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _hasCarrierShipment = shipments.isNotEmpty;
      _isCheckingCarrierShipment = false;
    });
  }

  void _confirmCancelOrder(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
            'Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _store.updateStatus(orderId, FulfillmentStatus.cancelled);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  /// Returns the next manual transition target per BE valid transitions.
  /// Returns null when no manual action is allowed (carrier-driven or terminal).
  FulfillmentStatus? _getNextStatus(FulfillmentStatus current) {
    switch (current) {
      case FulfillmentStatus.newOrder:
        return FulfillmentStatus.pending;
      case FulfillmentStatus.pending:
        return FulfillmentStatus.confirmed;
      case FulfillmentStatus.confirmed:
        return FulfillmentStatus.packing;
      case FulfillmentStatus.packing:
        return FulfillmentStatus.shipping;
      // shipping & partiallyShipped: no manual next — carrier webhook drives these.
      case FulfillmentStatus.shipping:
      case FulfillmentStatus.partiallyShipped:
        return null;
      // delivered → success is the only manual terminal transition.
      case FulfillmentStatus.delivered:
        return FulfillmentStatus.success;
      case FulfillmentStatus.success:
      case FulfillmentStatus.cancelled:
      case FulfillmentStatus.returned:
        return null;
    }
  }

  IconData _getStatusIcon(FulfillmentStatus status) {
    switch (status) {
      case FulfillmentStatus.newOrder:
        return Icons.fiber_new_outlined;
      case FulfillmentStatus.pending:
        return Icons.hourglass_empty;
      case FulfillmentStatus.confirmed:
        return Icons.check_circle_outline;
      case FulfillmentStatus.packing:
        return Icons.inventory_2_outlined;
      case FulfillmentStatus.shipping:
        return Icons.local_shipping;
      case FulfillmentStatus.partiallyShipped:
        return Icons.local_shipping_outlined;
      case FulfillmentStatus.delivered:
        return Icons.done_all;
      case FulfillmentStatus.success:
        return Icons.verified;
      case FulfillmentStatus.cancelled:
        return Icons.cancel;
      case FulfillmentStatus.returned:
        return Icons.assignment_return;
    }
  }

  Widget _buildStatusChip(FulfillmentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(FulfillmentStatus status) {
    switch (status) {
      case FulfillmentStatus.newOrder:
        return Colors.grey.shade500;
      case FulfillmentStatus.pending:
        return Colors.orange;
      case FulfillmentStatus.confirmed:
        return Colors.indigo;
      case FulfillmentStatus.packing:
        return Colors.deepOrange;
      case FulfillmentStatus.shipping:
        return Colors.teal;
      case FulfillmentStatus.partiallyShipped:
        return Colors.cyan;
      case FulfillmentStatus.delivered:
        return Colors.green;
      case FulfillmentStatus.success:
        return Colors.green.shade700;
      case FulfillmentStatus.cancelled:
        return Colors.red;
      case FulfillmentStatus.returned:
        return Colors.grey;
    }
  }
}
