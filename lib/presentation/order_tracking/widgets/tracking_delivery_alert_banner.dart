import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';

class TrackingDeliveryAlertBanner extends StatelessWidget {
  const TrackingDeliveryAlertBanner({
    super.key,
    required this.selected,
  });

  final OrderTrackingScenario selected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    final Color bgColor = selected.deliveryAlertType == DeliveryAlertType.failed
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFFEF3C7);
    final Color borderColor =
        selected.deliveryAlertType == DeliveryAlertType.failed
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
                  selected.deliveryAlertMessage,
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
}
