import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';
import 'package:intl/intl.dart';

class PrintLabelScreen extends StatefulWidget {
  const PrintLabelScreen({super.key});

  @override
  State<PrintLabelScreen> createState() => _PrintLabelScreenState();
}

class _PrintLabelScreenState extends State<PrintLabelScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();
  List<ShipmentTrackingInfo> _shipments = const [];
  ShipmentTrackingInfo? _shipment;
  bool _loadingShipment = false;
  bool _submittingShipment = false;
  bool _shipFullRemaining = true;
  final Map<String, int> _manualAllocations = <String, int>{};

  bool _canManageShipment(FulfillmentOrder order) {
    return order.status == FulfillmentStatus.partiallyShipped ||
        order.status == FulfillmentStatus.shipped ||
        order.status == FulfillmentStatus.delivered;
  }

  String _displayShipmentStatus(
    FulfillmentOrder order,
    ShipmentTrackingInfo shipment,
  ) {
    final isTerminalOrder =
        order.status == FulfillmentStatus.delivered ||
        order.status == FulfillmentStatus.returned ||
        order.status == FulfillmentStatus.cancelled;

    if (isTerminalOrder) {
      return order.status.apiValue;
    }

    return shipment.status;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderId = _store.selectedOrder?.id;
      if (orderId != null) {
        _loadShipment(orderId, refresh: true);
      }
    });
  }

  Future<void> _loadShipment(String orderId, {bool refresh = false}) async {
    final order = _store.selectedOrder;
    if (order == null || !_canManageShipment(order)) {
      return;
    }

    if (_loadingShipment) {
      return;
    }

    setState(() {
      _loadingShipment = true;
    });

    final shipments = await _store.getOrderShipmentBatches(
      orderId,
      refresh: refresh,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _shipments = shipments;
      _shipment = shipments.isEmpty ? null : shipments.last;
      _loadingShipment = false;
    });
  }

  Future<void> _createShipment(
    FulfillmentOrder order, {
    List<CreateShipmentItemAllocation> items = const [],
  }) async {
    if (_submittingShipment) {
      return;
    }

    setState(() {
      _submittingShipment = true;
    });

    final result = await _store.createOrLinkShipment(order.id, items: items);

    if (!mounted) {
      return;
    }

    if (result != null) {
      await _loadShipment(order.id, refresh: true);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Shipment batch #${result.shipmentNumber} ready: ${result.trackingCode}',
          ),
        ),
      );
    }

    setState(() {
      _shipment = result;
      _submittingShipment = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final order = _store.selectedOrder;
        return Scaffold(
          appBar: AppBar(
            title: Text(order != null ? 'Labels ${order.code}' : 'Print Label'),
          ),
          body: order == null
              ? const Center(child: Text('No order selected'))
              : _buildBody(order),
        );
      },
    );
  }

  Widget _buildBody(FulfillmentOrder order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComingSoonBanner(),
          const SizedBox(height: 16),
          _buildShipmentSection(order),
          const SizedBox(height: 16),
          _buildLabelPreview(order),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: null, // Disabled until backend API supports labels
              icon: const Icon(Icons.print),
              label: const Text('Print Label'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentSection(FulfillmentOrder order) {
    final shipment = _shipment;
    final canManageShipment = _canManageShipment(order);
    final shippedByItem = _buildShippedByItemMap(_shipments);
    final remainingByItem = _buildRemainingByItemMap(order, shippedByItem);
    final hasRemainingItems =
      remainingByItem.values.any((remaining) => remaining > 0);
    final canCreateShipment =
      (order.status == FulfillmentStatus.shipped ||
        order.status == FulfillmentStatus.partiallyShipped) &&
      hasRemainingItems;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Carrier Integration',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (canManageShipment)
                IconButton(
                  tooltip: 'Refresh shipment',
                  onPressed: _loadingShipment
                      ? null
                      : () => _loadShipment(order.id, refresh: true),
                  icon: _loadingShipment
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
            ],
          ),
          if (!canManageShipment)
            Text(
              'Shipment actions are available when order status is Shipped, Partially Shipped, or Delivered.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (shipment == null)
            Text(
              'No shipment linked yet. Create a GHN shipment.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (shipment != null) ...[
            Text(
              'Shipment batches: ${_shipments.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Latest: ${shipment.provider.toUpperCase()} • #${shipment.shipmentNumber} • ${shipment.trackingCode}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Status: ${_displayShipmentStatus(order, shipment)}'),
            if (order.status == FulfillmentStatus.delivered &&
                shipment.status.toLowerCase() != 'delivered')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Order status has been synchronized via webhook. Provider detail may take time to converge.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (shipment.latestNote != null && shipment.latestNote!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(shipment.latestNote!),
              ),
            if (shipment.estimatedDelivery != null &&
                order.status != FulfillmentStatus.delivered)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'ETA: ${DateFormat('dd/MM/yyyy HH:mm').format(shipment.estimatedDelivery!)}',
                ),
              ),
          ],
          if (canCreateShipment) ...[
            const SizedBox(height: 12),
            _buildPartialAllocationSection(order, remainingByItem),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submittingShipment
                    ? null
                    : () {
                        final allocations = _buildAllocationsForCreate(order, remainingByItem);
                        if (allocations == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please pick at least one item quantity for partial shipment.'),
                            ),
                          );
                          return;
                        }
                        _createShipment(order, items: allocations);
                      },
                icon: const Icon(Icons.local_shipping_outlined),
                label: Text(
                  _shipFullRemaining
                      ? 'Create GHN Shipment (Full Remaining)'
                      : 'Create GHN Shipment (Partial)',
                ),
              ),
            ),
          ],
          if (!hasRemainingItems)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'All order items are already allocated to shipment batches.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (
            (order.status == FulfillmentStatus.shipped ||
                order.status == FulfillmentStatus.partiallyShipped) &&
            shipment != null
          )
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'You can create next shipment batch for remaining items. Carrier status will be synchronized via refresh/webhook.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPartialAllocationSection(
    FulfillmentOrder order,
    Map<String, int> remainingByItem,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 18),
              const SizedBox(width: 8),
              Text(
                'Shipment Allocation',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('Ship full remaining items'),
            value: _shipFullRemaining,
            onChanged: (value) {
              setState(() {
                _shipFullRemaining = value;
              });
            },
          ),
          if (!_shipFullRemaining) ...[
            const SizedBox(height: 4),
            ...order.items.map((item) {
              final remaining = remainingByItem[item.id] ?? 0;
              final selected = (_manualAllocations[item.id] ?? 0).clamp(0, remaining);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Remaining: $remaining',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: remaining == 0
                          ? null
                          : () {
                              final next = selected > 0 ? selected - 1 : 0;
                              setState(() {
                                _manualAllocations[item.id] = next;
                              });
                            },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '$selected',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: remaining == 0 || selected >= remaining
                          ? null
                          : () {
                              final next = selected + 1;
                              setState(() {
                                _manualAllocations[item.id] = next;
                              });
                            },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Map<String, int> _buildShippedByItemMap(List<ShipmentTrackingInfo> shipments) {
    final shipped = <String, int>{};
    for (final shipment in shipments) {
      for (final item in shipment.items) {
        shipped[item.orderItemId] = (shipped[item.orderItemId] ?? 0) + item.quantity;
      }
    }
    return shipped;
  }

  Map<String, int> _buildRemainingByItemMap(
    FulfillmentOrder order,
    Map<String, int> shippedByItem,
  ) {
    final remaining = <String, int>{};
    for (final item in order.items) {
      final shippedQty = shippedByItem[item.id] ?? 0;
      final value = item.quantity - shippedQty;
      remaining[item.id] = value > 0 ? value : 0;
    }
    return remaining;
  }

  List<CreateShipmentItemAllocation>? _buildAllocationsForCreate(
    FulfillmentOrder order,
    Map<String, int> remainingByItem,
  ) {
    if (_shipFullRemaining) {
      return const <CreateShipmentItemAllocation>[];
    }

    final allocations = <CreateShipmentItemAllocation>[];
    for (final item in order.items) {
      final remaining = remainingByItem[item.id] ?? 0;
      final picked = (_manualAllocations[item.id] ?? 0).clamp(0, remaining);
      if (picked > 0) {
        allocations.add(
          CreateShipmentItemAllocation(orderItemId: item.id, quantity: picked),
        );
      }
    }

    if (allocations.isEmpty) {
      return null;
    }

    return allocations;
  }

  Widget _buildComingSoonBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coming Soon',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Label printing will be available with backend API integration.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelPreview(FulfillmentOrder order) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.black),
            child: Text(
              'SHIPPING LABEL',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender
                _buildLabelSection(
                  'FROM',
                  'Mobile AI ERP Warehouse',
                  '100 Nguyen Van Linh, District 7\nHo Chi Minh City, Vietnam',
                  'Tel: 028-1234-5678',
                ),
                const Divider(height: 24, thickness: 1),
                // Receiver
                _buildLabelSection(
                  'TO',
                  order.customerName,
                  order.shippingAddress ?? 'N/A',
                  'Tel: ${order.customerPhone ?? 'N/A'}',
                ),
                const Divider(height: 24, thickness: 1),
                // Order info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabelField('ORDER', order.code),
                          const SizedBox(height: 8),
                          _buildLabelField(
                            'ITEMS',
                            '${order.items.length} product(s)',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabelField('SOURCE', order.source),
                          const SizedBox(height: 8),
                          _buildLabelField('PAYMENT', order.paymentStatus),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelSection(
    String title,
    String name,
    String address,
    String phone,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(address, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(phone, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildLabelField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
