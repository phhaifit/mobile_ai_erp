import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/dto/order_detail_response.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/utils/order_tracking_order_info.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/order_tracking_shared_widgets.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/store/order_tracking_store.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_carrier_card.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_current_status_card.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_delivery_alert_banner.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_detailed_timeline_card.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_return_exchange_card.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_timeline_header.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final OrderTrackingStore _orderTrackingStore = getIt<OrderTrackingStore>();
  bool _isSeededFromRouteArgs = false;
  String? _orderId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isSeededFromRouteArgs) {
      return;
    }

    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final String orderId = (args['orderId'] ?? '').toString().trim();
      if (orderId.isNotEmpty) {
        _orderId = orderId;
        _orderTrackingStore.startRealtimeTracking(orderId);
      }
    }
    _isSeededFromRouteArgs = true;
  }

  @override
  void dispose() {
    _orderTrackingStore.stopRealtimeTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final AppLocalizations t = AppLocalizations.of(context);
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        final double width = MediaQuery.sizeOf(context).width;
        final bool isCompact = width < 420;
        final bool isWideLayout = width >= 960;
        final double contentMaxWidth = isWideLayout ? 1200 : 860;
        final OrderTrackingScenario? selected =
            _orderTrackingStore.selectedScenario;
        final OrderDetailResponse? orderDetail =
            _orderTrackingStore.orderDetail;
        final String title = _tr(t, 'tracking_title', 'Order Tracking');

        if (_orderTrackingStore.isLoading) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (_orderTrackingStore.errorMessage != null) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _orderTrackingStore.errorMessage ?? 'Unable to load order',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_orderId != null && _orderId!.isNotEmpty) {
                        _orderTrackingStore.startRealtimeTracking(_orderId!);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (selected == null) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            body: Center(
              child: Text(
                _orderId == null || _orderId!.isEmpty
                    ? 'Missing order ID.'
                    : 'No order details available.',
              ),
            ),
          );
        }

        final OrderTrackingScenario selectedScenario = selected;
        final bool isReturnFlow =
            selectedScenario.returnExchangeStage != ReturnExchangeStage.none;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Column(
                  children: <Widget>[
                    if (!isReturnFlow)
                      TrackingTimelineHeader(
                        selected: selectedScenario,
                        primaryColor: colorScheme.primary,
                        shipmentStageLabel: (ShipmentStage stage) =>
                            _shipmentStageLabel(stage, t),
                        orderIdLabel:
                            _tr(t, 'tracking_order_id_label', 'Order ID'),
                      ),
                    if (orderDetail != null) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          isWideLayout ? 20 : 16,
                          20,
                          isWideLayout ? 20 : 16,
                          0,
                        ),
                        child: _buildOrderSummaryCard(
                          context: context,
                          detail: orderDetail,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          isWideLayout ? 20 : 16,
                          12,
                          isWideLayout ? 20 : 16,
                          0,
                        ),
                        child: _buildLiveIndicator(context),
                      ),
                    ],
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isWideLayout ? 20 : 16,
                        20,
                        isWideLayout ? 20 : 16,
                        24,
                      ),
                      child: isWideLayout
                          ? _buildWideContent(
                              isCompact: isCompact,
                              selectedScenario: selectedScenario,
                              t: t,
                              colorScheme: colorScheme,
                              isReturnFlow: isReturnFlow,
                            )
                          : _buildNarrowContent(
                              isCompact: isCompact,
                              selectedScenario: selectedScenario,
                              t: t,
                              colorScheme: colorScheme,
                              isReturnFlow: isReturnFlow,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNarrowContent({
    required bool isCompact,
    required OrderTrackingScenario selectedScenario,
    required AppLocalizations t,
    required ColorScheme colorScheme,
    required bool isReturnFlow,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TrackingCurrentStatusCard(
          selected: selectedScenario,
          primaryColor: colorScheme.primary,
          shipmentStageLabel: (ShipmentStage stage) =>
              _shipmentStageLabel(stage, t),
          formatDateTime: _formatDateTime,
          estimatedDeliveryLabel: _tr(
            t,
            'tracking_estimated_delivery',
            'Estimated delivery',
          ),
          deliveredAtLabel: _tr(
            t,
            'tracking_delivered_at',
            'Delivered at',
          ),
        ),
        if (selectedScenario.returnExchangeStage !=
            ReturnExchangeStage.none) ...<Widget>[
          const SizedBox(height: 16),
          TrackingReturnExchangeCard(
            selected: selectedScenario,
            returnStageLabel: (ReturnExchangeStage stage) =>
                _returnStageLabel(stage, t),
            primaryColor: colorScheme.primary,
            title: _tr(
              t,
              'tracking_return_exchange_title',
              'Return / Exchange',
            ),
          ),
        ],
        const SizedBox(height: 16),
        TrackingCarrierCard(
          selected: selectedScenario,
          primaryColor: colorScheme.primary,
          onOpenCarrierUrl: _openCarrierUrl,
          sectionTitle: _tr(
            t,
            'tracking_carrier_section_title',
            'Carrier information',
          ),
          carrierNameLabel: _tr(
            t,
            'tracking_carrier_name_label',
            'Carrier',
          ),
          trackingNumberLabel: _tr(
            t,
            'tracking_number_label',
            'Tracking number',
          ),
        ),
        const SizedBox(height: 16),
        if (selectedScenario.deliveryAlertType !=
            DeliveryAlertType.none) ...<Widget>[
          TrackingDeliveryAlertBanner(
            selected: selectedScenario,
            title: _tr(
              t,
              'tracking_delivery_notification_title',
              'Delivery notification',
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (!isReturnFlow)
          TrackingDetailedTimelineCard(
            selected: selectedScenario,
            shipmentStageLabel: (ShipmentStage stage) =>
                _shipmentStageLabel(stage, t),
            formatDateTime: _formatDateTime,
            timelineTitle: _tr(
              t,
              'tracking_timeline_title',
              'Shipment timeline',
            ),
            pendingLabel: _tr(
              t,
              'tracking_pending',
              'Pending',
            ),
          ),
      ],
    );
  }

  Widget _buildWideContent({
    required bool isCompact,
    required OrderTrackingScenario selectedScenario,
    required AppLocalizations t,
    required ColorScheme colorScheme,
    required bool isReturnFlow,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (selectedScenario.returnExchangeStage !=
                      ReturnExchangeStage.none)
                    TrackingReturnExchangeCard(
                      selected: selectedScenario,
                      returnStageLabel: (ReturnExchangeStage stage) =>
                          _returnStageLabel(stage, t),
                      primaryColor: colorScheme.primary,
                      title: _tr(
                        t,
                        'tracking_return_exchange_title',
                        'Return / Exchange',
                      ),
                    ),
                  if (selectedScenario.returnExchangeStage !=
                      ReturnExchangeStage.none)
                    const SizedBox(height: 16),
                  if (!isReturnFlow)
                    TrackingDetailedTimelineCard(
                      selected: selectedScenario,
                      shipmentStageLabel: (ShipmentStage stage) =>
                          _shipmentStageLabel(stage, t),
                      formatDateTime: _formatDateTime,
                      timelineTitle: _tr(
                        t,
                        'tracking_timeline_title',
                        'Shipment timeline',
                      ),
                      pendingLabel: _tr(
                        t,
                        'tracking_pending',
                        'Pending',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TrackingCurrentStatusCard(
                    selected: selectedScenario,
                    primaryColor: colorScheme.primary,
                    shipmentStageLabel: (ShipmentStage stage) =>
                        _shipmentStageLabel(stage, t),
                    formatDateTime: _formatDateTime,
                    estimatedDeliveryLabel: _tr(
                      t,
                      'tracking_estimated_delivery',
                      'Estimated delivery',
                    ),
                    deliveredAtLabel: _tr(
                      t,
                      'tracking_delivered_at',
                      'Delivered at',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TrackingCarrierCard(
                    selected: selectedScenario,
                    primaryColor: colorScheme.primary,
                    onOpenCarrierUrl: _openCarrierUrl,
                    sectionTitle: _tr(
                      t,
                      'tracking_carrier_section_title',
                      'Carrier information',
                    ),
                    carrierNameLabel: _tr(
                      t,
                      'tracking_carrier_name_label',
                      'Carrier',
                    ),
                    trackingNumberLabel: _tr(
                      t,
                      'tracking_number_label',
                      'Tracking number',
                    ),
                  ),
                  if (selectedScenario.deliveryAlertType !=
                      DeliveryAlertType.none) ...<Widget>[
                    const SizedBox(height: 16),
                    TrackingDeliveryAlertBanner(
                      selected: selectedScenario,
                      title: _tr(
                        t,
                        'tracking_delivery_notification_title',
                        'Delivery notification',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummaryCard({
    required BuildContext context,
    required OrderDetailResponse detail,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final NumberFormat currencyFormat = NumberFormat.decimalPattern('vi_VN');

    final OrderInfo info = OrderInfoMapper.fromDetail(detail);
    final DateTime? createdAt = info.createdAt;
    final String createdLabel = createdAt == null
      ? ''
      : DateFormat('dd MMM yyyy, HH:mm').format(createdAt);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.code,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      info.customerName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: formatOrderStatus(info.status),
                background: getOrderStatusColor(info.status, colorScheme),
              ),
            ],
          ),
          if (info.deliveryInfo.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              info.deliveryInfo,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.65),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: InfoRow(
                  label: 'Total',
                  value: '${formatOrderPrice(info.totalPrice, currencyFormat)} đ',
                  valueStyle: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (info.itemsCount > 0)
                Expanded(
                  child: InfoRow(
                    label: 'Items',
                    value: '${info.itemsCount} items',
                    alignEnd: true,
                    valueStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                )
              else if (createdLabel.isNotEmpty)
                Expanded(
                  child: InfoRow(
                    label: 'Created',
                    value: createdLabel,
                    alignEnd: true,
                    valueStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
          if (info.itemsCount > 0 && createdLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            InfoRow(
              label: 'Created',
              value: createdLabel,
              valueStyle: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openCarrierUrl(String url) async {
    final Uri uri = Uri.parse(url);
    final bool launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      final AppLocalizations t = AppLocalizations.of(context);
      _showSnackBar(
        _tr(
          t,
          'tracking_error_open_carrier_link',
          'Unable to open carrier link.',
        ),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _shipmentStageLabel(ShipmentStage stage, AppLocalizations t) {
    switch (stage) {
      case ShipmentStage.confirmed:
        return _tr(t, 'tracking_stage_confirmed', 'Confirmed');
      case ShipmentStage.packed:
        return _tr(t, 'tracking_stage_packed', 'Packed');
      case ShipmentStage.shipped:
        return _tr(t, 'tracking_stage_shipped', 'Shipped');
      case ShipmentStage.delivered:
        return _tr(t, 'tracking_stage_delivered', 'Delivered');
    }
  }

  String _returnStageLabel(ReturnExchangeStage stage, AppLocalizations t) {
    switch (stage) {
      case ReturnExchangeStage.none:
        return _tr(t, 'tracking_return_none', 'No return request');
      case ReturnExchangeStage.requested:
        return _tr(t, 'tracking_return_requested', 'Requested');
      case ReturnExchangeStage.approved:
        return _tr(t, 'tracking_return_approved', 'Approved');
      case ReturnExchangeStage.inTransitBack:
        return _tr(
          t,
          'tracking_return_in_transit_back',
          'In transit back',
        );
      case ReturnExchangeStage.received:
        return _tr(t, 'tracking_return_received', 'Received');
      case ReturnExchangeStage.refunded:
        return _tr(t, 'tracking_return_refunded', 'Refunded');
      case ReturnExchangeStage.exchanged:
        return _tr(t, 'tracking_return_exchanged', 'Exchanged');
    }
  }

  String _tr(AppLocalizations t, String key, String fallback) {
    try {
      return t.translate(key);
    } catch (_) {
      return fallback;
    }
  }

  String _formatDateTime(DateTime value) {
    return DateFormat('dd MMM yyyy, HH:mm').format(value);
  }

  Widget _buildLiveIndicator(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime? lastUpdated = _orderTrackingStore.lastUpdatedAt;
    final String lastUpdatedLabel = lastUpdated == null
        ? 'Updating...'
        : 'Last updated: ${DateFormat('HH:mm:ss').format(lastUpdated)}';

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _orderTrackingStore.isPolling
                ? Colors.green
                : colorScheme.outline,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Live tracking',
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withOpacity(0.75),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          lastUpdatedLabel,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

}
