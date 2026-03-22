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
  @override
  State<FulfillmentDetailScreen> createState() =>
      _FulfillmentDetailScreenState();
}

class _FulfillmentDetailScreenState extends State<FulfillmentDetailScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
  late ReactionDisposer _errorDisposer;

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
        return Scaffold(
          appBar: AppBar(
            title: Text(order.id),
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
          _buildInfoRow(Icons.phone_outlined, 'Phone', order.customerPhone),
          _buildInfoRow(
              Icons.location_on_outlined, 'Address', order.shippingAddress),
          _buildInfoRow(Icons.storefront, 'Channel', order.channel),
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
          ...order.items.map((item) => _buildItemTile(order, item)),
        ],
      ),
    );
  }

  Widget _buildItemTile(FulfillmentOrder order, FulfillmentItem item) {
    final canPick = order.status == FulfillmentStatus.picking ||
        order.status == FulfillmentStatus.pending;

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
            const SizedBox(height: 8),
            Row(
              children: [
                _buildProgressIndicator(
                    'Picked', item.pickedQuantity, item.quantity, Colors.blue),
                const SizedBox(width: 12),
                _buildProgressIndicator(
                    'Packed', item.packedQuantity, item.quantity, Colors.purple),
                const SizedBox(width: 12),
                _buildProgressIndicator(
                    'Shipped', item.shippedQuantity, item.quantity, Colors.teal),
              ],
            ),
            if (canPick) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (item.pickedQuantity > 0)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 22),
                      tooltip: 'Pick -1',
                      onPressed: () => _store.updatePickedQuantity(
                          order.id, item.id, item.pickedQuantity - 1),
                    ),
                  if (!item.isFullyPicked)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 22),
                      tooltip: 'Pick +1',
                      onPressed: () => _store.updatePickedQuantity(
                          order.id, item.id, item.pickedQuantity + 1),
                    ),
                  if (!item.isFullyPicked)
                    TextButton.icon(
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Pick All'),
                      onPressed: () => _store.updatePickedQuantity(
                          order.id, item.id, item.quantity),
                    ),
                  if (item.isFullyPicked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'Fully Picked',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
      String label, int current, int total, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: $current/$total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).hintColor,
                ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? current / total : 0,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(FulfillmentOrder order) {
    final nextStatus = _getNextStatus(order.status);
    if (nextStatus == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () => _store.updateStatus(order.id, nextStatus),
            icon: Icon(_getStatusIcon(nextStatus)),
            label: Text('Mark as ${nextStatus.displayName}'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          if (order.status == FulfillmentStatus.shipped) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _store.updateStatus(
                  order.id, FulfillmentStatus.partiallyDelivered),
              icon: const Icon(Icons.call_split),
              label: const Text('Mark as Partially Delivered'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
          if (order.status != FulfillmentStatus.cancelled &&
              order.status != FulfillmentStatus.delivered) ...[
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

  FulfillmentStatus? _getNextStatus(FulfillmentStatus current) {
    switch (current) {
      case FulfillmentStatus.pending:
        return FulfillmentStatus.picking;
      case FulfillmentStatus.picking:
        return FulfillmentStatus.packing;
      case FulfillmentStatus.packing:
        return FulfillmentStatus.packed;
      case FulfillmentStatus.packed:
        return FulfillmentStatus.shipped;
      case FulfillmentStatus.shipped:
        return FulfillmentStatus.delivered;
      case FulfillmentStatus.partiallyDelivered:
        return FulfillmentStatus.delivered;
      case FulfillmentStatus.delivered:
      case FulfillmentStatus.cancelled:
        return null;
    }
  }

  IconData _getStatusIcon(FulfillmentStatus status) {
    switch (status) {
      case FulfillmentStatus.pending:
        return Icons.hourglass_empty;
      case FulfillmentStatus.picking:
        return Icons.shopping_cart;
      case FulfillmentStatus.packing:
        return Icons.inventory;
      case FulfillmentStatus.packed:
        return Icons.check_box;
      case FulfillmentStatus.shipped:
        return Icons.local_shipping;
      case FulfillmentStatus.partiallyDelivered:
        return Icons.call_split;
      case FulfillmentStatus.delivered:
        return Icons.done_all;
      case FulfillmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  Widget _buildStatusChip(FulfillmentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.15),
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
      case FulfillmentStatus.pending:
        return Colors.orange;
      case FulfillmentStatus.picking:
        return Colors.blue;
      case FulfillmentStatus.packing:
        return Colors.indigo;
      case FulfillmentStatus.packed:
        return Colors.purple;
      case FulfillmentStatus.shipped:
        return Colors.teal;
      case FulfillmentStatus.partiallyDelivered:
        return Colors.amber.shade800;
      case FulfillmentStatus.delivered:
        return Colors.green;
      case FulfillmentStatus.cancelled:
        return Colors.red;
    }
  }
}
