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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    const List<ShipmentStage> stages = <ShipmentStage>[
      ShipmentStage.confirmed,
      ShipmentStage.packed,
      ShipmentStage.shipped,
      ShipmentStage.delivered,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.12),
            width: 1,
          ),
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
                            : colorScheme.onSurface.withValues(alpha: 0.12),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.translate('tracking_order_id_label'),
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          Text(
            selected.orderId,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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
            color: isDone
                ? primaryColor
                : colorScheme.onSurface.withValues(alpha: 0.12),
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
                ? Icon(Icons.check, color: colorScheme.onPrimary, size: 22)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
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
              color: isDone
                  ? primaryColor
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
