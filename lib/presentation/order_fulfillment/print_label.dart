import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/fulfillment_order.dart';
import 'package:mobile_ai_erp/domain/entity/fulfillment/shipment_tracking.dart';
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';
import 'package:intl/intl.dart';

class PrintLabelScreen extends StatefulWidget {
  @override
  State<PrintLabelScreen> createState() => _PrintLabelScreenState();
}

class _PrintLabelScreenState extends State<PrintLabelScreen> {
  final FulfillmentStore _store = getIt<FulfillmentStore>();
  ShipmentTrackingInfo? _shipment;
  bool _loadingShipment = false;
  bool _submittingShipment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderId = _store.selectedOrder?.id;
      if (orderId != null) {
        _loadShipment(orderId);
      }
    });
  }

  Future<void> _loadShipment(String orderId, {bool refresh = false}) async {
    if (_loadingShipment) {
      return;
    }

    setState(() {
      _loadingShipment = true;
    });

    final shipment = await _store.getShipmentTracking(
      orderId,
      refresh: refresh,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _shipment = shipment;
      _loadingShipment = false;
    });
  }

  Future<void> _createShipment(FulfillmentOrder order) async {
    if (_submittingShipment) {
      return;
    }

    setState(() {
      _submittingShipment = true;
    });

    final result = await _store.createOrLinkShipment(order.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _shipment = result;
      _submittingShipment = false;
    });

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Shipment ready: ${result.trackingCode}')),
      );
    }
  }

  Future<void> _showLinkTrackingDialog(FulfillmentOrder order) async {
    final controller = TextEditingController();

    final trackingCode = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Link Existing Tracking Code'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tracking code',
            hintText: 'e.g. 5ENLKKHD',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Link'),
          ),
        ],
      ),
    );

    if (trackingCode == null || trackingCode.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _submittingShipment = true;
    });

    final result = await _store.createOrLinkShipment(
      order.id,
      trackingCode: trackingCode,
      note: 'Linked from mobile app',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _shipment = result;
      _submittingShipment = false;
    });

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Linked tracking: ${result.trackingCode}')),
      );
    }
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
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
          if (shipment == null)
            Text(
              'No shipment linked yet. Create a GHN shipment or link an existing tracking code.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (shipment != null) ...[
            Text(
              '${shipment.provider.toUpperCase()} • ${shipment.trackingCode}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Status: ${shipment.status}'),
            if (shipment.latestNote != null && shipment.latestNote!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(shipment.latestNote!),
              ),
            if (shipment.estimatedDelivery != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'ETA: ${DateFormat('dd/MM/yyyy HH:mm').format(shipment.estimatedDelivery!)}',
                ),
              ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _submittingShipment
                      ? null
                      : () => _createShipment(order),
                  icon: const Icon(Icons.local_shipping_outlined),
                  label: Text(
                    shipment == null ? 'Create GHN Shipment' : 'Re-create',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _submittingShipment
                      ? null
                      : () => _showLinkTrackingDialog(order),
                  icon: const Icon(Icons.link),
                  label: const Text('Link Tracking'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
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
