import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/tracking_event.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';
import 'package:intl/intl.dart';

class FulfillmentTrackingScreen extends StatefulWidget {
  @override
  State<FulfillmentTrackingScreen> createState() => _FulfillmentTrackingScreenState();
}

class _FulfillmentTrackingScreenState extends State<FulfillmentTrackingScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final order = _store.selectedOrder;
        return Scaffold(
          appBar: AppBar(
            title: Text(order != null ? 'Tracking ${order.id}' : 'Tracking'),
          ),
          body: order == null
              ? const Center(child: Text('No order selected'))
              : _buildTrackingBody(order.trackingEvents, order.status),
        );
      },
    );
  }

  Widget _buildTrackingBody(
      List<TrackingEvent> events, FulfillmentStatus currentStatus) {
    if (events.isEmpty) {
      return const Center(child: Text('No tracking events'));
    }

    final sortedEvents = List<TrackingEvent>.from(events)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentStatusBanner(currentStatus),
          const SizedBox(height: 24),
          Text(
            'Timeline',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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

  Widget _buildCurrentStatusBanner(FulfillmentStatus status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
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
    final color = isFirst
        ? _getStatusColor(event.status)
        : _getStatusColor(event.status).withOpacity(0.5);

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
                      color: color.withOpacity(0.3),
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
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.status.displayName,
                              style: TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM HH:mm').format(event.timestamp),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (event.location != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 14, color: Theme.of(context).hintColor),
                            const SizedBox(width: 4),
                            Text(
                              event.location!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      ],
                      if (event.updatedBy != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 14, color: Theme.of(context).hintColor),
                            const SizedBox(width: 4),
                            Text(
                              event.updatedBy!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context).hintColor),
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
}
