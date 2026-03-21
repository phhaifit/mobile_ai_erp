import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ai_erp/data/repository/order_tracking/order_tracking_repository_impl.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/domain/repository/order_tracking/order_tracking_repository.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final OrderTrackingRepository _repository = OrderTrackingRepositoryImpl();
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  bool _isSeededFromRouteArgs = false;

  // Shopee-inspired color palette
  static const Color _primaryColor = Color(0xFF0F766E);      // Teal

  late List<OrderTrackingScenario> _scenarios;
  late OrderTrackingScenario _selected;

  @override
  void initState() {
    super.initState();
    _scenarios = _repository.getScenarios();
    _selected = _scenarios.first;
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
    final AppLocalizations t = AppLocalizations.of(context);
    final bool isCompact = MediaQuery.sizeOf(context).width < 420;

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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Horizontal Timeline (Shopee-style)
            _buildHorizontalTimeline(t),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildPublicLookupCard(t),
                  const SizedBox(height: 16),
                  _buildScenarioSelector(t, isCompact),
                  const SizedBox(height: 16),
                  _buildCurrentStatusCard(t),
                  const SizedBox(height: 16),
                  _buildCarrierCard(t),
                  const SizedBox(height: 16),
                  if (_selected.deliveryAlertType != DeliveryAlertType.none)
                    ...<Widget>[
                      _buildDeliveryAlertBanner(t),
                      const SizedBox(height: 16),
                    ],
                  _buildDetailedTimelineCard(t),
                  const SizedBox(height: 16),
                  if (_selected.returnExchangeStage != ReturnExchangeStage.none)
                    _buildReturnExchangeCard(t),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shopee-style horizontal timeline showing all shipment stages
  Widget _buildHorizontalTimeline(AppLocalizations t) {
    const List<ShipmentStage> stages = <ShipmentStage>[
      ShipmentStage.confirmed,
      ShipmentStage.packed,
      ShipmentStage.shipped,
      ShipmentStage.delivered,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 80,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < stages.length; i++) ...<Widget>[
                  Expanded(
                    child: _buildTimelineStage(
                      stages[i],
                      i,
                      stages.length,
                      t,
                    ),
                  ),
                  if (i < stages.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Container(
                        height: 2,
                        color: _selected.currentStage.index > i
                            ? _primaryColor
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.translate('tracking_order_id_label'),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
          Text(
            _selected.orderId,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  /// Build single timeline stage circle
  Widget _buildTimelineStage(
    ShipmentStage stage,
    int index,
    int totalStages,
    AppLocalizations t,
  ) {
    final bool isDone = _selected.currentStage.index >= stage.index;
    final bool isCurrent = _selected.currentStage == stage;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? _primaryColor : const Color(0xFFE5E7EB),
            boxShadow: isCurrent
                ? <BoxShadow>[
                    BoxShadow(
                      color: _primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          child: Text(
            _shipmentStageLabel(stage, t),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isDone ? _primaryColor : const Color(0xFF9CA3AF),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  /// Shopee-style section card with subtle design
  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: child,
    );
  }

  /// Build section title with optional icon
  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Row(
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 18, color: _primaryColor),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildPublicLookupCard(AppLocalizations t) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle(
            t.translate('tracking_lookup_title'),
            icon: Icons.search_rounded,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _orderIdController,
            decoration: InputDecoration(
              labelText: t.translate('tracking_order_id_label'),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenController,
            decoration: InputDecoration(
              labelText: t.translate('tracking_token_label'),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _simulateLookup,
              icon: const Icon(Icons.travel_explore_outlined, size: 20),
              label: Text(t.translate('tracking_lookup_button')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioSelector(AppLocalizations t, bool isCompact) {
    return _buildCard(
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildSectionTitle(
                  t.translate('tracking_scenario_label'),
                  icon: Icons.tune_rounded,
                ),
                const SizedBox(height: 12),
                _buildScenarioDropdown(),
              ],
            )
          : Row(
              children: <Widget>[
                Expanded(
                  child: _buildSectionTitle(
                    t.translate('tracking_scenario_label'),
                    icon: Icons.tune_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildScenarioDropdown()),
              ],
            ),
    );
  }

  Widget _buildScenarioDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButton<OrderTrackingScenario>(
        isExpanded: true,
        underline: const SizedBox.shrink(),
        value: _selected,
        items: _scenarios
            .map(
              (OrderTrackingScenario item) => DropdownMenuItem<OrderTrackingScenario>(
                value: item,
                child: Text(item.scenarioName),
              ),
            )
            .toList(),
        onChanged: (OrderTrackingScenario? data) {
          if (data == null) {
            return;
          }
          setState(() {
            _selected = data;
          });
        },
      ),
    );
  }

  /// Current order status - Shopee-style prominent display
  Widget _buildCurrentStatusCard(AppLocalizations t) {
    return _buildCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _shipmentStageLabel(_selected.currentStage, t),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.translate('tracking_estimated_delivery'),
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDateTime(_selected.estimatedDeliveryDate),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrierCard(AppLocalizations t) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle(
            t.translate('tracking_carrier_section_title'),
            icon: Icons.local_shipping_outlined,
          ),
          const SizedBox(height: 14),
          _buildCarrierInfo(
            '${t.translate('tracking_carrier_name_label')}:',
            _selected.carrierName,
          ),
          const SizedBox(height: 10),
          _buildCarrierInfo(
            '${t.translate('tracking_number_label')}:',
            _selected.trackingNumber,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primaryColor, width: 1),
                foregroundColor: _primaryColor,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _openCarrierUrl(_selected.carrierTrackingUrl),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(t.translate('tracking_open_carrier_link')),
            ),
          ),
        ],
      ),
    );
  }

  /// Build carrier info row
  Widget _buildCarrierInfo(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryAlertBanner(AppLocalizations t) {
    final Color bgColor = _selected.deliveryAlertType == DeliveryAlertType.failed
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFFEF3C7);

    final Color borderColor = _selected.deliveryAlertType == DeliveryAlertType.failed
        ? const Color(0xFFFCA5A5)
        : const Color(0xFFFCD34D);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.warning_rounded, size: 20, color: Color(0xFFD97706)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  t.translate('tracking_delivery_notification_title'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selected.deliveryAlertMessage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Detailed timeline showing all shipment updates
  Widget _buildDetailedTimelineCard(AppLocalizations t) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle(
            t.translate('tracking_timeline_title'),
            icon: Icons.route_outlined,
          ),
          const SizedBox(height: 14),
          ..._selected.timelineSteps.asMap().entries.map((entry) {
            final int index = entry.key;
            final TrackingTimelineStep step = entry.value;
            final bool isDone = _selected.currentStage.index >= step.stage.index;
            final bool isLast = index == _selected.timelineSteps.length - 1;

            return _buildDetailedTimelineItem(
              label: _shipmentStageLabel(step.stage, t),
              dateText: step.timestamp == null
                  ? t.translate('tracking_pending')
                  : _formatDateTime(step.timestamp!),
              isActive: _selected.currentStage == step.stage,
              isDone: isDone,
              showConnector: !isLast,
            );
          }),
        ],
      ),
    );
  }

  /// Build single detailed timeline item
  Widget _buildDetailedTimelineItem({
    required String label,
    required String dateText,
    required bool isActive,
    required bool isDone,
    required bool showConnector,
  }) {
    final Color markerColor = isDone ? _primaryColor : const Color(0xFFD1D5DB);

    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? markerColor : Colors.white,
                    border: Border.all(color: markerColor, width: 2),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (showConnector)
                  Container(
                    width: 2,
                    height: 28,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: isDone
                        ? markerColor.withValues(alpha: 0.3)
                        : const Color(0xFFE5E7EB),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive ? _primaryColor : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showConnector) const SizedBox(height: 0),
      ],
    );
  }

  Widget _buildReturnExchangeCard(AppLocalizations t) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle(
            t.translate('tracking_return_exchange_title'),
            icon: Icons.swap_horiz_rounded,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
            ),
            child: Text(
              _returnStageLabel(_selected.returnExchangeStage, t),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateLookup() {
    final AppLocalizations t = AppLocalizations.of(context);
    final String orderId = _orderIdController.text.trim();
    final String token = _tokenController.text.trim();

    if (orderId.isEmpty || token.isEmpty) {
      _showSnackBar(t.translate('tracking_error_enter_order_and_token'));
      return;
    }

    final OrderTrackingScenario? found = _repository.findByOrderId(
      _scenarios,
      orderId,
    );

    if (found == null) {
      _showSnackBar(t.translate('tracking_error_order_not_found'));
      return;
    }

    // Mock token validation rule for Phase 1: token must be at least 6 chars.
    if (token.length < 6) {
      _showSnackBar(t.translate('tracking_error_token_invalid'));
      return;
    }

    setState(() {
      _selected = found;
    });
  }

  Future<void> _openCarrierUrl(String url) async {
    final Uri uri = Uri.parse(url);
    final bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

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
