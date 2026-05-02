import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_status.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/order_print_label.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';
import 'package:intl/intl.dart';

class FulfillmentShipmentScreen extends StatefulWidget {
  const FulfillmentShipmentScreen({super.key});

  @override
  State<FulfillmentShipmentScreen> createState() => _FulfillmentShipmentScreenState();
}

class _FulfillmentShipmentScreenState extends State<FulfillmentShipmentScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();
  List<ShipmentTrackingInfo> _shipments = const [];
  bool _loadingShipment = false;
  bool _submittingShipment = false;
  bool _loadingRouting = false;
  bool _applyingRouting = false;
  bool _shipFullRemaining = true;
  OrderRoutingRecommendation? _routingRecommendation;
  String? _selectedRoutingOptionId;
  final Map<String, int> _manualAllocations = <String, int>{};

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
    if (_loadingShipment) return;
    setState(() => _loadingShipment = true);
    final shipments = await _store.getOrderShipmentBatches(orderId, refresh: refresh);
    if (!mounted) return;
    setState(() {
      _shipments = shipments;
      _loadingShipment = false;
    });
  }

  Future<void> _loadRoutingRecommendation(String orderId, {bool forceNew = false}) async {
    if (_loadingRouting) return;
    setState(() => _loadingRouting = true);
    final recommendation = await _store.getOrderRoutingRecommendation(orderId, forceNew: forceNew);
    if (!mounted) return;
    setState(() {
      _routingRecommendation = recommendation;
      
      // Fix: Use the specific selectedOptionId returned from BE
      if (recommendation?.selectedOptionId != null) {
        _selectedRoutingOptionId = recommendation!.selectedOptionId;
      } else if (recommendation?.selectedProvider != null && recommendation!.options.isNotEmpty) {
        // Fallback for older decisions that only have provider
        final appliedOption = recommendation.options.firstWhere(
          (o) => o.provider.toLowerCase() == recommendation.selectedProvider!.toLowerCase(),
          orElse: () => recommendation.options.first,
        );
        _selectedRoutingOptionId = appliedOption.optionId;
      } else if (recommendation?.options.isNotEmpty == true) {
        _selectedRoutingOptionId = recommendation!.options.first.optionId;
      } else {
        _selectedRoutingOptionId = null;
      }
      
      _loadingRouting = false;
    });
  }

  Future<void> _applyRouting(FulfillmentOrder order) async {
    if (_applyingRouting || _routingRecommendation == null) return;
    setState(() => _applyingRouting = true);
    final result = await _store.applyOrderRoutingRecommendation(
      order.id,
      decisionId: _routingRecommendation!.decisionId,
      selectedOptionId: _selectedRoutingOptionId,
    );
    if (!mounted) return;
    setState(() => _applyingRouting = false);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Carrier selected: ${result.selectedProvider.toUpperCase()}')),
      );
      _loadRoutingRecommendation(order.id);
    }
  }

  Future<void> _createShipment(FulfillmentOrder order) async {
    if (_submittingShipment) return;

    final shippedByItem = _buildShippedByItemMap(_shipments);
    final remainingByItem = _buildRemainingByItemMap(order, shippedByItem);
    final allocations = _buildAllocationsForCreate(order, remainingByItem);

    if (!_shipFullRemaining && (allocations == null || allocations.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item quantity.')),
      );
      return;
    }

    setState(() => _submittingShipment = true);
    final result = await _store.createOrLinkShipment(order.id, items: allocations ?? []);
    
    if (!mounted) return;

    if (result != null) {
      if (order.status == FulfillmentStatus.confirmed || order.status == FulfillmentStatus.packing) {
        await _store.updateStatus(order.id, FulfillmentStatus.shipping);
      }
      await _loadShipment(order.id, refresh: true);
      if (!mounted) return;
      _showSuccessDialog(order, result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create shipment. Please try again.')),
      );
    }
    
    setState(() => _submittingShipment = false);
  }

  void _showSuccessDialog(FulfillmentOrder order, ShipmentTrackingInfo shipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Shipment Created'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Batch #${shipment.shipmentNumber} generated successfully.'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text(shipment.trackingCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => OrderPrintLabelScreen(shipment: shipment)));
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Label'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final order = _store.selectedOrder;
        if (order == null) return const Scaffold(body: Center(child: Text('No order selected')));

        final shippedByItem = _buildShippedByItemMap(_shipments);
        final remainingByItem = _buildRemainingByItemMap(order, shippedByItem);
        final remainingItems = order.items.where((i) => (remainingByItem[i.id] ?? 0) > 0).toList();
        final isAllShipped = remainingItems.isEmpty;

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text('Fulfillment Manifest'),
            elevation: 0,
          ),
          body: _loadingShipment && _shipments.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHeaderInfo(order),
                      const SizedBox(height: 16),
                      if (!isAllShipped) ...[
                        _buildRoutingStep(order),
                        const SizedBox(height: 16),
                        _buildAllocationStep(order, remainingItems, remainingByItem),
                        const SizedBox(height: 24),
                        _buildSubmitButton(order, remainingByItem),
                      ] else ...[
                        _buildCompletionCard(),
                      ],
                      const SizedBox(height: 24),
                      _buildHistorySection(order),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeaderInfo(FulfillmentOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.inventory_2, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Customer: ${order.customerName}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              ],
            ),
          ),
          _buildStatusChip(order.status),
        ],
      ),
    );
  }

  RoutingRecommendationOption? _getRecommendedOption() {
    if (_routingRecommendation == null || _routingRecommendation!.options.isEmpty) return null;
    return _routingRecommendation!.options.reduce((a, b) => a.score > b.score ? a : b);
  }

  Widget _buildRoutingStep(FulfillmentOrder order) {
    final recommendation = _routingRecommendation;
    final isApplied = recommendation?.selectedProvider != null;
    final options = recommendation?.options ?? [];

    return _buildSectionCard(
      title: 'Carrier Selection (AI)',
      subtitle: 'Optimize delivery speed and cost',
      icon: Icons.auto_awesome,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loadingRouting) const LinearProgressIndicator(),
          if (recommendation != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates, color: Colors.indigo, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Recommended: ${_routingRecommendation?.recommendedProvider.toUpperCase()} - ${_getRecommendedOption()?.serviceLevel.toUpperCase() ?? ""}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRoutingOptionId,
              isExpanded: true,
              autovalidateMode: AutovalidateMode.disabled,
              items: options.map((o) => DropdownMenuItem(
                value: o.optionId,
                child: Text('${o.provider.toUpperCase()} - ${o.estimatedCost.toStringAsFixed(0)}đ (${o.serviceLevel})'),
              )).toList(),
              onChanged: isApplied ? null : (v) => setState(() => _selectedRoutingOptionId = v),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.indigo.shade400)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12), 
                labelText: 'Select Carrier',
                labelStyle: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: isApplied ? null : () => _applyRouting(order),
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text(isApplied ? 'CARRIER APPLIED' : 'CONFIRM SELECTION'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllocationStep(FulfillmentOrder order, List<dynamic> remainingItems, Map<String, int> remainingByItem) {
    return _buildSectionCard(
      title: 'Shipment Allocation',
      subtitle: 'Select items to include in this batch',
      icon: Icons.local_shipping,
      content: Column(
        children: [
          SwitchListTile.adaptive(
            title: const Text('Ship all remaining items', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            value: _shipFullRemaining,
            onChanged: (v) => setState(() => _shipFullRemaining = v),
          ),
          if (!_shipFullRemaining) ...[
            const Divider(),
            ...remainingItems.map((item) {
              final remaining = remainingByItem[item.id] ?? 0;
              final selected = (_manualAllocations[item.id] ?? 0).clamp(0, remaining);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.productName, style: const TextStyle(fontSize: 14)),
                subtitle: Text('In stock: $remaining', style: const TextStyle(fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => setState(() => _manualAllocations[item.id] = (selected - 1).clamp(0, remaining))),
                    Text('$selected', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => setState(() => _manualAllocations[item.id] = (selected + 1).clamp(0, remaining))),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(FulfillmentOrder order, Map<String, int> remainingByItem) {
    // Validation logic for button enabled state
    bool hasValidAllocation = _shipFullRemaining;
    if (!_shipFullRemaining) {
      // Check if at least one item has a quantity > 0
      hasValidAllocation = _manualAllocations.entries.any((entry) {
        final remaining = remainingByItem[entry.key] ?? 0;
        return entry.value > 0 && entry.value <= remaining;
      });
    }

    final canSubmit = !_submittingShipment && hasValidAllocation;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canSubmit ? () => _createShipment(order) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade200,
          disabledForegroundColor: Colors.grey.shade400,
          elevation: canSubmit ? 2 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _submittingShipment
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('CREATE GHN SHIPMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.1)),
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.shade100)),
      child: Column(
        children: [
          const Icon(Icons.task_alt, color: Colors.green, size: 48),
          const SizedBox(height: 16),
          const Text('All Items Fulfilled', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('All products have been allocated to shipment batches.', textAlign: TextAlign.center, style: TextStyle(color: Colors.green.shade800, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildHistorySection(FulfillmentOrder order) {
    if (_shipments.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('Shipment History', style: TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        ..._shipments.map((s) => Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            title: Text('Batch #${s.shipmentNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Code: ${s.trackingCode} • ${s.status}', style: const TextStyle(fontSize: 12)),
            trailing: IconButton(icon: const Icon(Icons.print, color: Colors.blue, size: 20), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderPrintLabelScreen(shipment: s)))),
          ),
        )),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required String subtitle, required IconData icon, required Widget content}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.indigo.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(FulfillmentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
      child: Text(status.displayName, style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
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

  Map<String, int> _buildRemainingByItemMap(FulfillmentOrder order, Map<String, int> shippedByItem) {
    final remaining = <String, int>{};
    for (final item in order.items) {
      final shippedQty = shippedByItem[item.id] ?? 0;
      final value = item.quantity - shippedQty;
      remaining[item.id] = value > 0 ? value : 0;
    }
    return remaining;
  }

  List<CreateShipmentItemAllocation>? _buildAllocationsForCreate(FulfillmentOrder order, Map<String, int> remainingByItem) {
    if (_shipFullRemaining) return const [];
    final allocations = <CreateShipmentItemAllocation>[];
    for (final item in order.items) {
      final remaining = remainingByItem[item.id] ?? 0;
      final picked = (_manualAllocations[item.id] ?? 0).clamp(0, remaining);
      if (picked > 0) {
        allocations.add(CreateShipmentItemAllocation(orderItemId: item.id, quantity: picked));
      }
    }
    return allocations.isEmpty ? null : allocations;
  }
}
