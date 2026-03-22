import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/store/order_tracking_store.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_carrier_card.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_current_status_card.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_delivery_alert_banner.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_detailed_timeline_card.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_return_exchange_card.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_scenario_selector.dart';
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

  @override
  void initState() {
    super.initState();
    _orderTrackingStore.loadScenarios();
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
        final OrderTrackingScenario? found =
            _orderTrackingStore.findByOrderId(orderId);
        if (found != null) {
          _orderTrackingStore.selectScenario(found);
        }
      }
    }
    _isSeededFromRouteArgs = true;
  }

  @override
  void dispose() {
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
        final String title = _tr(t, 'tracking_title', 'Order Tracking');

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
            body: const Center(child: CircularProgressIndicator()),
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
        TrackingScenarioSelector(
          isCompact: isCompact,
          scenarios: _scenarios,
          selected: selectedScenario,
          primaryColor: colorScheme.primary,
          onChanged: _orderTrackingStore.selectScenario,
          scenarioLabel: _tr(
            t,
            'tracking_scenario_label',
            'Tracking scenario',
          ),
        ),
        const SizedBox(height: 16),
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
        TrackingScenarioSelector(
          isCompact: isCompact,
          scenarios: _scenarios,
          selected: selectedScenario,
          primaryColor: colorScheme.primary,
          onChanged: _orderTrackingStore.selectScenario,
          scenarioLabel: _tr(
            t,
            'tracking_scenario_label',
            'Tracking scenario',
          ),
        ),
        const SizedBox(height: 16),
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

  List<OrderTrackingScenario> get _scenarios => _orderTrackingStore.scenarios;

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
}
