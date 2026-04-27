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
  List<ShipmentLabelArtifact> _labelArtifacts = const [];
  List<ShipmentPrintJob> _printJobs = const [];
  bool _loadingShipment = false;
  bool _loadingPrintData = false;
  bool _submittingShipment = false;
  bool _submittingPrint = false;
  bool _loadingRouting = false;
  bool _applyingRouting = false;
  bool _shipFullRemaining = true;
  OrderRoutingRecommendation? _routingRecommendation;
  String? _selectedRoutingOptionId;
  final Map<String, int> _manualAllocations = <String, int>{};

  bool _canManageShipment(FulfillmentOrder order) {
    // Shipment actions are available from first shipping status through completion.
    return order.status == FulfillmentStatus.shipping ||
        order.status == FulfillmentStatus.partiallyShipped ||
        order.status == FulfillmentStatus.delivered ||
        order.status == FulfillmentStatus.success;
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
        _loadRoutingRecommendation(orderId);
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

    if (shipments.isEmpty) {
      setState(() {
        _labelArtifacts = const [];
        _printJobs = const [];
      });
      await _loadRoutingRecommendation(orderId);
      return;
    }

    await _loadPrintData(orderId, _shipment!.id);
    await _loadRoutingRecommendation(orderId);
  }

  Future<void> _loadRoutingRecommendation(
    String orderId, {
    bool forceNew = false,
  }) async {
    if (_loadingRouting) {
      return;
    }

    setState(() {
      _loadingRouting = true;
    });

    final recommendation = await _store.getOrderRoutingRecommendation(
      orderId,
      forceNew: forceNew,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _routingRecommendation = recommendation;
      _selectedRoutingOptionId = recommendation?.options.isNotEmpty == true
          ? recommendation!.options.first.optionId
          : null;
      _loadingRouting = false;
    });
  }

  Future<void> _applyRoutingRecommendation(FulfillmentOrder order) async {
    final recommendation = _routingRecommendation;
    if (recommendation == null || _applyingRouting) {
      return;
    }

    setState(() {
      _applyingRouting = true;
    });

    final result = await _store.applyOrderRoutingRecommendation(
      order.id,
      decisionId: recommendation.decisionId,
      selectedOptionId: _selectedRoutingOptionId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _applyingRouting = false;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot apply routing recommendation. Please retry.'),
        ),
      );
      return;
    }

    await _loadRoutingRecommendation(order.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Routing applied: ${result.selectedProvider.toUpperCase()}. Next shipment will use this decision.',
        ),
      ),
    );
  }

  Future<void> _loadPrintData(String orderId, String shipmentId) async {
    if (_loadingPrintData) {
      return;
    }

    setState(() {
      _loadingPrintData = true;
    });

    final labels = await _store.getShipmentLabelArtifacts(orderId, shipmentId);
    final jobs = await _store.getShipmentPrintJobs(orderId, shipmentId);

    if (!mounted) {
      return;
    }

    setState(() {
      _labelArtifacts = labels;
      _printJobs = jobs;
      _loadingPrintData = false;
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

    await _loadShipment(order.id, refresh: true);

    if (!mounted) {
      return;
    }

    if (result != null) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Shipment batch #${result.shipmentNumber} ready: ${result.trackingCode}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create shipment failed. Please review remaining allocation and retry.'),
        ),
      );
    }

    setState(() {
      _shipment = result;
      _submittingShipment = false;
    });
  }

  Future<void> _printLatestShipmentLabel(FulfillmentOrder order) async {
    final shipment = _shipment;
    if (shipment == null || _submittingPrint) {
      return;
    }

    setState(() {
      _submittingPrint = true;
    });

    final startedAt = DateTime.now();

    final createdJob = await _store.createShipmentPrintJob(
      order.id,
      shipment.id,
      artifactType: 'shipping_label',
      format: 'pdf',
      printerName: 'Mobile Preview Printer',
      printerCode: 'MOBILE-PREVIEW',
      copies: 1,
      metadata: {
        'source': 'mobile_ai_erp',
        'screen': 'print_label',
      },
    );

    if (!mounted) {
      return;
    }

    if (createdJob == null) {
      setState(() {
        _submittingPrint = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot queue print job. Please retry.'),
        ),
      );
      return;
    }

    final completedJob = await _store.createShipmentPrintAttempt(
      order.id,
      shipment.id,
      createdJob.id,
      status: 'succeeded',
      spoolJobId: 'mobile-${DateTime.now().millisecondsSinceEpoch}',
      durationMs: DateTime.now().difference(startedAt).inMilliseconds,
      printerResponse: {
        'channel': 'mobile-preview',
        'message': 'Preview print acknowledged by mobile client',
      },
    );

    if (!mounted) {
      return;
    }

    await _loadPrintData(order.id, shipment.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _submittingPrint = false;
    });

    final finalStatus = completedJob?.status ?? createdJob.status;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Print job queued with status: $finalStatus'),
      ),
    );
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
    final canPrint =
        _canManageShipment(order) && _shipment != null && !_submittingPrint;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrintIntegrationBanner(order),
          const SizedBox(height: 16),
          _buildRoutingRecommendationSection(order),
          const SizedBox(height: 16),
          _buildShipmentSection(order),
          const SizedBox(height: 16),
          _buildLabelPreview(order),
          const SizedBox(height: 16),
          _buildPrintQueueSection(order),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canPrint ? () => _printLatestShipmentLabel(order) : null,
              icon: const Icon(Icons.print),
              label: Text(
                _submittingPrint ? 'Printing...' : 'Print Label',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildPrintButtonHint(order),
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
      (order.status == FulfillmentStatus.shipping ||
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
              'Shipment actions are available when order status is Shipping, Partially Shipped, or Delivered.',
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
            const SizedBox(height: 12),
            _buildShipmentBatchesList(order, _shipments),
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
            (order.status == FulfillmentStatus.shipping ||
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

  Widget _buildRoutingRecommendationSection(FulfillmentOrder order) {
    final recommendation = _routingRecommendation;
    final canCreateShipment =
        order.status == FulfillmentStatus.shipping ||
        order.status == FulfillmentStatus.partiallyShipped;
    final isApplied = recommendation?.selectedProvider != null;

    if (!canCreateShipment) {
      return const SizedBox.shrink();
    }

    final options = recommendation?.options ?? const <RoutingRecommendationOption>[];
    final selectedOption = options.firstWhere(
      (option) => option.optionId == _selectedRoutingOptionId,
      orElse: () => options.isNotEmpty
          ? options.first
          : const RoutingRecommendationOption(
              optionId: '',
              provider: 'ghn',
              serviceLevel: 'standard',
              score: 0,
              estimatedDeliveryDays: 0,
              estimatedCost: 0,
              reason: '',
            ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'AI Routing (MVP)',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh recommendation',
                onPressed: _loadingRouting
                    ? null
                    : () => _loadRoutingRecommendation(order.id, forceNew: true),
                icon: _loadingRouting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),
          if (recommendation == null)
            Text(
              'No routing recommendation loaded yet. Fetch a recommendation before creating shipment.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (recommendation != null) ...[
            Text(
              'Recommended provider: ${recommendation.recommendedProvider.toUpperCase()} • Strategy: ${recommendation.scoreStrategy}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (recommendation.confidence != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Confidence: ${(recommendation.confidence! * 100).toStringAsFixed(1)}%'
                  '${recommendation.fallbackUsed ? ' • Fallback mode' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 8),
            if (options.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: _selectedRoutingOptionId,
                items: options
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option.optionId,
                        child: Text(
                          '${option.provider.toUpperCase()} ${option.serviceLevel} • ${option.estimatedDeliveryDays}d • ${option.estimatedCost.toStringAsFixed(0)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: isApplied
                    ? null
                    : (value) {
                        setState(() {
                          _selectedRoutingOptionId = value;
                        });
                      },
                decoration: const InputDecoration(
                  labelText: 'Recommendation Options',
                  isDense: true,
                ),
              ),
            if (options.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  selectedOption.reason,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (_applyingRouting || isApplied)
                        ? null
                        : () => _applyRoutingRecommendation(order),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      _applyingRouting
                          ? 'Applying...'
                          : isApplied
                              ? 'Applied'
                              : 'Apply Recommendation',
                    ),
                  ),
                ),
              ],
            ),
            if (recommendation.selectedProvider != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Applied provider: ${recommendation.selectedProvider!.toUpperCase()}. Refresh to generate and apply a new decision for next shipment batch.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartialAllocationSection(
    FulfillmentOrder order,
    Map<String, int> remainingByItem,
  ) {
    final remainingItems = order.items
        .where((item) => (remainingByItem[item.id] ?? 0) > 0)
        .toList();

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
            if (remainingItems.isEmpty)
              Text(
                'No remaining items for manual allocation.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ...remainingItems.map((item) {
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

  Widget _buildShipmentBatchesList(
    FulfillmentOrder order,
    List<ShipmentTrackingInfo> shipments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Shipment Batches',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        ...shipments.map((batch) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Batch #${batch.shipmentNumber} • ${batch.provider.toUpperCase()} • ${batch.trackingCode}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text('Status: ${batch.status}'),
                if (batch.items.isNotEmpty)
                  Text(
                    _buildBatchItemsText(order, batch),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (batch.latestNote != null && batch.latestNote!.isNotEmpty)
                  Text(
                    batch.latestNote!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _buildBatchItemsText(
    FulfillmentOrder order,
    ShipmentTrackingInfo batch,
  ) {
    final orderItemsById = {
      for (final item in order.items) item.id: item,
    };

    final chunks = batch.items.map((shipmentItem) {
      final orderItem = orderItemsById[shipmentItem.orderItemId];
      final productName = orderItem?.productName ?? shipmentItem.orderItemId;
      return '$productName x${shipmentItem.quantity}';
    }).toList();

    return 'Items: ${chunks.join(', ')}';
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

  Widget _buildPrintIntegrationBanner(FulfillmentOrder order) {
    final canManageShipment = _canManageShipment(order);
    final hasShipment = _shipment != null;

    final title = canManageShipment
        ? hasShipment
            ? 'Printing Queue Connected'
            : 'Waiting For Shipment Batch'
        : 'Printing Locked By Order Status';

    final description = canManageShipment
        ? hasShipment
            ? 'This screen queues shipment print jobs and tracks print attempts from backend API.'
            : 'Please create or link at least one shipment batch before printing labels.'
        : 'Print label is available only when order status is Shipping, Partially Shipped, or Delivered.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.print_outlined, color: Colors.teal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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

  Widget _buildPrintButtonHint(FulfillmentOrder order) {
    if (_submittingPrint) {
      return Text(
        'Submitting print job and attempt to backend...',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    if (!_canManageShipment(order)) {
      return Text(
        'Current status: ${order.status.displayName}. Print is enabled only for Shipping, Partially Shipped, Delivered, or Completed.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    if (_shipment == null) {
      return Text(
        'No shipment batch found yet. Create a shipment above, then Print Label will be enabled.',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Text(
      'Ready to print for shipment batch #${_shipment!.shipmentNumber}.',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  Widget _buildPrintQueueSection(FulfillmentOrder order) {
    final shipment = _shipment;
    if (shipment == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Print Queue',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadingPrintData
                    ? null
                    : () => _loadPrintData(order.id, shipment.id),
                icon: _loadingPrintData
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),
          Text(
            'Artifacts: ${_labelArtifacts.length} • Jobs: ${_printJobs.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          if (_printJobs.isEmpty)
            Text(
              'No print jobs yet. Tap Print Label to queue a job.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ..._printJobs.take(5).map((job) {
            final latestAttempt =
                job.attempts.isNotEmpty ? job.attempts.last : null;
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Job ${job.id.substring(0, 8)} • ${job.status.toUpperCase()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Queued: ${DateFormat('dd/MM HH:mm:ss').format(job.queuedAt)} • Copies: ${job.copies}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (latestAttempt != null)
                    Text(
                      'Latest attempt #${latestAttempt.attemptNo}: ${latestAttempt.status}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (job.lastErrorMessage != null &&
                      job.lastErrorMessage!.isNotEmpty)
                    Text(
                      job.lastErrorMessage!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.red.shade700),
                    ),
                ],
              ),
            );
          }),
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
