import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';

class TrackingCurrentStatusCard extends StatelessWidget {
  const TrackingCurrentStatusCard({
    super.key,
    required this.selected,
    required this.primaryColor,
    required this.shipmentStageLabel,
    required this.formatDateTime,
    required this.estimatedDeliveryLabel,
  });

  final OrderTrackingScenario selected;
  final Color primaryColor;
  final String Function(ShipmentStage stage) shipmentStageLabel;
  final String Function(DateTime value) formatDateTime;
  final String estimatedDeliveryLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDelivered = selected.currentStage == ShipmentStage.delivered;
    final DateTime displayDateTime = isDelivered
        ? _deliveredAt ?? selected.estimatedDeliveryDate
        : selected.estimatedDeliveryDate;

    return _SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              shipmentStageLabel(selected.currentStage),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isDelivered ? 'Delivered at' : estimatedDeliveryLabel,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatDateTime(displayDateTime),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  DateTime? get _deliveredAt {
    for (final TrackingTimelineStep step in selected.timelineSteps) {
      if (step.stage == ShipmentStage.delivered) {
        return step.timestamp;
      }
    }

    return null;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.12), width: 1),
      ),
      child: child,
    );
  }
}
