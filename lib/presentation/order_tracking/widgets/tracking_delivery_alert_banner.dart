import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';

class TrackingDeliveryAlertBanner extends StatelessWidget {
  const TrackingDeliveryAlertBanner({
    super.key,
    required this.selected,
    required this.title,
  });

  final OrderTrackingScenario selected;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Color bgColor = selected.deliveryAlertType == DeliveryAlertType.failed
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer.withValues(alpha: 0.45);
    final Color borderColor =
        selected.deliveryAlertType == DeliveryAlertType.failed
            ? colorScheme.error
            : colorScheme.primary.withValues(alpha: 0.45);

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
          Icon(
            Icons.warning_rounded,
            size: 20,
            color: selected.deliveryAlertType == DeliveryAlertType.failed
                ? colorScheme.error
                : colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selected.deliveryAlertMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
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
}
