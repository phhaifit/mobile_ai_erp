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
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_lookup_card.dart';
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
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  bool _isSeededFromRouteArgs = false;

  static const Color _primaryColor = Color(0xFF0F766E);

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
      _orderIdController.text = (args['orderId'] ?? '').toString();
      _tokenController.text = (args['token'] ?? '').toString();
    }
    _isSeededFromRouteArgs = true;
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final AppLocalizations t = AppLocalizations.of(context);
        final bool isCompact = MediaQuery.sizeOf(context).width < 420;
        final OrderTrackingScenario? selected =
            _orderTrackingStore.selectedScenario;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1B1B1B),
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
                      TrackingTimelineHeader(
                        selected: _selected,
                        primaryColor: _primaryColor,
                        shipmentStageLabel: _shipmentStageLabel,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TrackingLookupCard(
                              orderIdController: _orderIdController,
                              tokenController: _tokenController,
                              primaryColor: _primaryColor,
                              onLookup: _simulateLookup,
                            ),
                            const SizedBox(height: 16),
                            TrackingScenarioSelector(
                              isCompact: isCompact,
                              scenarios: _scenarios,
                              selected: _selected,
                              primaryColor: _primaryColor,
                              onChanged: _orderTrackingStore.selectScenario,
                            ),
                            const SizedBox(height: 16),
                            TrackingCurrentStatusCard(
                              selected: _selected,
                              primaryColor: _primaryColor,
                              shipmentStageLabel: _shipmentStageLabel,
                              formatDateTime: _formatDateTime,
                            ),
                            const SizedBox(height: 16),
                            TrackingCarrierCard(
                              selected: _selected,
                              primaryColor: _primaryColor,
                              onOpenCarrierUrl: _openCarrierUrl,
                            ),
                            const SizedBox(height: 16),
                            if (_selected.deliveryAlertType !=
                                DeliveryAlertType.none) ...<Widget>[
                              TrackingDeliveryAlertBanner(selected: _selected),
                              const SizedBox(height: 16),
                            ],
                            TrackingDetailedTimelineCard(
                              selected: _selected,
                              shipmentStageLabel: _shipmentStageLabel,
                              formatDateTime: _formatDateTime,
                            ),
                            const SizedBox(height: 16),
                            if (_selected.returnExchangeStage !=
                                ReturnExchangeStage.none)
                              TrackingReturnExchangeCard(
                                selected: _selected,
                                returnStageLabel: _returnStageLabel,
                                primaryColor: _primaryColor,
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

  void _simulateLookup() {
    final AppLocalizations t = AppLocalizations.of(context);
    final String orderId = _orderIdController.text.trim();
    final String token = _tokenController.text.trim();

    if (orderId.isEmpty || token.isEmpty) {
      _showSnackBar(t.translate('tracking_error_enter_order_and_token'));
      return;
    }

    final OrderTrackingScenario? found =
        _orderTrackingStore.findByOrderId(orderId);

    if (found == null) {
      _showSnackBar(t.translate('tracking_error_order_not_found'));
      return;
    }

    if (token.length < 6) {
      _showSnackBar(t.translate('tracking_error_token_invalid'));
      return;
    }

    _orderTrackingStore.selectScenario(found);
  }

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
