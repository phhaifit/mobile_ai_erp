import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/timeline_item.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';

class TrackingDetailedTimelineCard extends StatelessWidget {
  const TrackingDetailedTimelineCard({
    super.key,
    required this.selected,
    required this.shipmentStageLabel,
    required this.formatDateTime,
  });

  final OrderTrackingScenario selected;
  final String Function(ShipmentStage stage, AppLocalizations t)
      shipmentStageLabel;
  final String Function(DateTime value) formatDateTime;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionTitle(
            title: t.translate('tracking_timeline_title'),
            icon: Icons.route_outlined,
          ),
          const SizedBox(height: 14),
          ...selected.timelineSteps.asMap().entries.map((entry) {
            final int index = entry.key;
            final TrackingTimelineStep step = entry.value;
            final bool isDone = selected.currentStage.index >= step.stage.index;
            final bool isLast = index == selected.timelineSteps.length - 1;

            return TimelineItem(
              label: shipmentStageLabel(step.stage, t),
              dateText: step.timestamp == null
                  ? t.translate('tracking_pending')
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: const Color(0xFF0F766E)),
        const SizedBox(width: 8),
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
}
