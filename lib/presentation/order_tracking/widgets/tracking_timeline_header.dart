import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';

class TrackingTimelineHeader extends StatelessWidget {
  const TrackingTimelineHeader({
    super.key,
    required this.selected,
    required this.primaryColor,
    required this.shipmentStageLabel,
  });

  final OrderTrackingScenario selected;
  final Color primaryColor;
  final String Function(ShipmentStage stage, AppLocalizations t)
      shipmentStageLabel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
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
                    child: _TimelineStage(
                      stage: stages[i],
                      index: i,
                      selected: selected,
                      primaryColor: primaryColor,
                      label: shipmentStageLabel(stages[i], t),
                    ),
                  ),
                  if (i < stages.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Container(
                        height: 2,
                        color: selected.currentStage.index > i
                            ? primaryColor
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
            selected.orderId,
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
}

class _TimelineStage extends StatelessWidget {
  const _TimelineStage({
    required this.stage,
    required this.index,
    required this.selected,
    required this.primaryColor,
    required this.label,
  });

  final ShipmentStage stage;
  final int index;
  final OrderTrackingScenario selected;
  final Color primaryColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool isDone = selected.currentStage.index >= stage.index;
    final bool isCurrent = selected.currentStage == stage;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? primaryColor : const Color(0xFFE5E7EB),
            boxShadow: isCurrent
                ? <BoxShadow>[
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
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
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isDone ? primaryColor : const Color(0xFF9CA3AF),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
