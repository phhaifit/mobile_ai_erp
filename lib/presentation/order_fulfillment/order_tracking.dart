import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/tracking_event.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';
import 'package:intl/intl.dart';

class FulfillmentTrackingScreen extends StatefulWidget {
  const FulfillmentTrackingScreen({super.key});

  @override
  State<FulfillmentTrackingScreen> createState() =>
      _FulfillmentTrackingScreenState();
}

class _FulfillmentTrackingScreenState extends State<FulfillmentTrackingScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();
  List<ShipmentTrackingInfo> _shipments = const [];
  ShipmentTrackingInfo? _shipment;
  bool _isRefreshingCarrier = false;

  bool _canUseCarrierTracking(FulfillmentStatus status) {
    return status == FulfillmentStatus.partiallyShipped ||
        status == FulfillmentStatus.shipped ||
        status == FulfillmentStatus.delivered;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCarrierTracking(refresh: true);
    });
  }

  Future<void> _loadCarrierTracking({required bool refresh}) async {
    final order = _store.selectedOrder;
    final orderId = order?.id;
    if (
      orderId == null ||
      order == null ||
      !_canUseCarrierTracking(order.status) ||
      _isRefreshingCarrier
    ) {
      return;
    }

    setState(() {
      _isRefreshingCarrier = true;
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
      _isRefreshingCarrier = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final order = _store.selectedOrder;
        final canUseCarrierTracking =
            order != null && _canUseCarrierTracking(order.status);
        return Scaffold(
          appBar: AppBar(
            title: Text(order != null ? 'Tracking ${order.code}' : 'Tracking'),
            actions: canUseCarrierTracking
                ? [
                    IconButton(
                      tooltip: 'Refresh carrier tracking',
                      onPressed: _isRefreshingCarrier
                          ? null
                          : () => _loadCarrierTracking(refresh: true),
                      icon: _isRefreshingCarrier
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                    ),
                  ]
                : null,
          ),
          body: order == null
              ? const Center(child: Text('No order selected'))
              : _buildTrackingBody(
                  order.trackingEvents,
                  order.status,
                  _shipment,
                  _shipments,
                ),
        );
      },
    );
  }

  Widget _buildTrackingBody(
    List<TrackingEvent> events,
    FulfillmentStatus currentStatus,
    ShipmentTrackingInfo? shipment,
    List<ShipmentTrackingInfo> shipments,
  ) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            shipment == null
                ? 'No tracking events'
                : 'Tracking timeline will appear when carrier posts events.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final sortedEvents = List<TrackingEvent>.from(events)
      ..sort((a, b) => b.changedAt.compareTo(a.changedAt));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentStatusBanner(currentStatus),
          if (shipment != null) ...[
            const SizedBox(height: 12),
            Text(
              'Shipment batches: ${shipments.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            _buildCarrierCard(shipment, currentStatus),
          ],
          const SizedBox(height: 24),
          Text(
            'Timeline',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            sortedEvents.length,
            (index) => _buildTimelineItem(
              sortedEvents[index],
              isFirst: index == 0,
              isLast: index == sortedEvents.length - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrierCard(
    ShipmentTrackingInfo shipment,
    FulfillmentStatus currentStatus,
  ) {
    final eta = shipment.estimatedDelivery;
    final isTerminalOrder =
        currentStatus == FulfillmentStatus.delivered ||
        currentStatus == FulfillmentStatus.returned ||
        currentStatus == FulfillmentStatus.cancelled;

    final isCarrierOutOfSync =
        isTerminalOrder &&
        ((currentStatus == FulfillmentStatus.delivered &&
                shipment.status.toLowerCase() != 'delivered') ||
            (currentStatus == FulfillmentStatus.returned &&
                shipment.status.toLowerCase() != 'returned'));

    final displayCarrierStatus = isCarrierOutOfSync
        ? currentStatus.apiValue
        : shipment.status;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${shipment.provider.toUpperCase()} • ${shipment.trackingCode}',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text('Carrier status: $displayCarrierStatus'),
          if (isCarrierOutOfSync)
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
          if (eta != null && !isCarrierOutOfSync)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Estimated delivery: ${DateFormat('dd/MM/yyyy HH:mm').format(eta)}',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusBanner(FulfillmentStatus status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(status),
            size: 48,
            color: _getStatusColor(status),
          ),
          const SizedBox(height: 8),
          Text(
            status.displayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current Status',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    TrackingEvent event, {
    required bool isFirst,
    required bool isLast,
  }) {
    final displayNote = _normalizedEventNote(event.note);
    final color = isFirst
        ? _getStatusColor(event.newStatus)
      : _getStatusColor(event.newStatus).withValues(alpha: 0.5);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFirst ? color : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isFirst
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Card(
                elevation: isFirst ? 2 : 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.oldStatus != null
                                  ? '${event.oldStatus!.displayName} → ${event.newStatus.displayName}'
                                  : event.newStatus.displayName,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM HH:mm').format(event.changedAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                      if (displayNote != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          displayNote,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      if (event.changedByName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.changedByName!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(FulfillmentStatus status) {
    switch (status) {
      case FulfillmentStatus.pending:
        return Colors.orange;
      case FulfillmentStatus.processing:
        return Colors.blue;
      case FulfillmentStatus.partiallyShipped:
        return Colors.cyan;
      case FulfillmentStatus.shipped:
        return Colors.teal;
      case FulfillmentStatus.delivered:
        return Colors.green;
      case FulfillmentStatus.cancelled:
        return Colors.red;
      case FulfillmentStatus.returned:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(FulfillmentStatus status) {
    switch (status) {
      case FulfillmentStatus.pending:
        return Icons.hourglass_empty;
      case FulfillmentStatus.processing:
        return Icons.sync;
      case FulfillmentStatus.partiallyShipped:
        return Icons.local_shipping_outlined;
      case FulfillmentStatus.shipped:
        return Icons.local_shipping;
      case FulfillmentStatus.delivered:
        return Icons.done_all;
      case FulfillmentStatus.cancelled:
        return Icons.cancel;
      case FulfillmentStatus.returned:
        return Icons.assignment_return;
    }
  }

  String? _normalizedEventNote(String? rawNote) {
    if (rawNote == null) {
      return null;
    }

    final note = rawNote.trim();
    if (note.isEmpty) {
      return null;
    }

    final lower = note.toLowerCase();
    final hasNonAscii = note.runes.any((codePoint) => codePoint > 127);
    final hasSystemStatusToken =
      lower.contains('pending') ||
      lower.contains('confirmed') ||
      lower.contains('packing') ||
      lower.contains('processing') ||
      lower.contains('shipping') ||
      lower.contains('shipped') ||
      lower.contains('delivered') ||
      lower.contains('cancelled') ||
      lower.contains('returned');

    final isLegacyAutoMessage =
      hasNonAscii ||
      (lower.startsWith('status:') &&
        (lower.contains('system') || lower.contains('auto')));

    if (isLegacyAutoMessage && hasSystemStatusToken) {
      return 'Status updated automatically by system';
    }

    return note;
  }
}
