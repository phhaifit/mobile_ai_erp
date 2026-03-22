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
        final bool isCompact = MediaQuery.sizeOf(context).width < 420;
        final OrderTrackingScenario? selected =
            _orderTrackingStore.selectedScenario;
        final bool isReturnFlow =
            selected?.returnExchangeStage != ReturnExchangeStage.none;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            title: Text(
              t.translate('tracking_title'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          body: selected == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      if (!isReturnFlow)
                        TrackingTimelineHeader(
                          selected: _selected,
                          primaryColor: colorScheme.primary,
                          shipmentStageLabel: _shipmentStageLabel,
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TrackingScenarioSelector(
                              isCompact: isCompact,
                              scenarios: _scenarios,
                              selected: _selected,
                              primaryColor: colorScheme.primary,
                              onChanged: _orderTrackingStore.selectScenario,
                            ),
                            const SizedBox(height: 16),
                            TrackingCurrentStatusCard(
                              selected: _selected,
                              primaryColor: colorScheme.primary,
                              shipmentStageLabel: _shipmentStageLabel,
                              formatDateTime: _formatDateTime,
                            ),
                            if (_selected.returnExchangeStage !=
                                ReturnExchangeStage.none) ...<Widget>[
                              const SizedBox(height: 16),
                              TrackingReturnExchangeCard(
                                selected: _selected,
                                returnStageLabel: _returnStageLabel,
                                primaryColor: colorScheme.primary,
                              ),
                            ],
                            const SizedBox(height: 16),
                            TrackingCarrierCard(
                              selected: _selected,
                              primaryColor: colorScheme.primary,
                              onOpenCarrierUrl: _openCarrierUrl,
                            ),
                            const SizedBox(height: 16),
                            if (_selected.deliveryAlertType !=
                                DeliveryAlertType.none) ...<Widget>[
                              TrackingDeliveryAlertBanner(selected: _selected),
                              const SizedBox(height: 16),
                            ],
                            if (!isReturnFlow)
                              TrackingDetailedTimelineCard(
                                selected: _selected,
                                shipmentStageLabel: _shipmentStageLabel,
                                formatDateTime: _formatDateTime,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  List<OrderTrackingScenario> get _scenarios => _orderTrackingStore.scenarios;

  OrderTrackingScenario get _selected => _orderTrackingStore.selectedScenario!;

  Future<void> _openCarrierUrl(String url) async {
    final Uri uri = Uri.parse(url);
    final bool launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      final AppLocalizations t = AppLocalizations.of(context);
      _showSnackBar(t.translate('tracking_error_open_carrier_link'));
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
        return t.translate('tracking_stage_confirmed');
      case ShipmentStage.packed:
        return t.translate('tracking_stage_packed');
      case ShipmentStage.shipped:
        return t.translate('tracking_stage_shipped');
      case ShipmentStage.delivered:
        return t.translate('tracking_stage_delivered');
    }
  }

  String _returnStageLabel(ReturnExchangeStage stage, AppLocalizations t) {
    switch (stage) {
      case ReturnExchangeStage.none:
        return t.translate('tracking_return_none');
      case ReturnExchangeStage.requested:
        return t.translate('tracking_return_requested');
      case ReturnExchangeStage.approved:
        return t.translate('tracking_return_approved');
      case ReturnExchangeStage.inTransitBack:
        return t.translate('tracking_return_in_transit_back');
      case ReturnExchangeStage.received:
        return t.translate('tracking_return_received');
      case ReturnExchangeStage.refunded:
        return t.translate('tracking_return_refunded');
      case ReturnExchangeStage.exchanged:
        return t.translate('tracking_return_exchanged');
    }
  }

  String _formatDateTime(DateTime value) {
    return DateFormat('dd MMM yyyy, HH:mm').format(value);
  }
}
