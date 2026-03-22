import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_shared_section.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/timeline_item.dart';

class TrackingDetailedTimelineCard extends StatelessWidget {
  const TrackingDetailedTimelineCard({
    super.key,
    required this.selected,
    required this.shipmentStageLabel,
    required this.formatDateTime,
    required this.timelineTitle,
    required this.pendingLabel,
  });

  final OrderTrackingScenario selected;
  final String Function(ShipmentStage stage) shipmentStageLabel;
  final String Function(DateTime value) formatDateTime;
  final String timelineTitle;
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    return TrackingSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TrackingSectionTitle(
            title: timelineTitle,
            icon: Icons.route_outlined,
          ),
          const SizedBox(height: 14),
          ...selected.timelineSteps.asMap().entries.map((entry) {
            final int index = entry.key;
            final TrackingTimelineStep step = entry.value;
            final bool isDone = selected.currentStage.index >= step.stage.index;
            final bool isLast = index == selected.timelineSteps.length - 1;

            return TimelineItem(
              label: shipmentStageLabel(step.stage),
              dateText: step.timestamp == null
                  ? pendingLabel
                  : formatDateTime(step.timestamp!),
              isActive: selected.currentStage == step.stage,
              isDone: isDone,
              showLine: !isLast,
            );
          }),
        ],
      ),
    );
  }
}
