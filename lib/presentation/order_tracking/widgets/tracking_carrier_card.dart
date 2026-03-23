import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_shared_section.dart';

class TrackingCarrierCard extends StatelessWidget {
  const TrackingCarrierCard({
    super.key,
    required this.selected,
    required this.primaryColor,
    required this.onOpenCarrierUrl,
    required this.sectionTitle,
    required this.carrierNameLabel,
    required this.trackingNumberLabel,
  });

  final OrderTrackingScenario selected;
  final Color primaryColor;
  final ValueChanged<String> onOpenCarrierUrl;
  final String sectionTitle;
  final String carrierNameLabel;
  final String trackingNumberLabel;

  @override
  Widget build(BuildContext context) {
    return TrackingSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TrackingSectionTitle(
            title: sectionTitle,
            icon: Icons.local_shipping_outlined,
            iconColor: primaryColor,
          ),
          const SizedBox(height: 14),
          _CarrierInfo(
            label: '$carrierNameLabel:',
            value: selected.carrierName,
          ),
          const SizedBox(height: 10),
          _CarrierInfo(
            label: '$trackingNumberLabel:',
            value: selected.trackingNumber,
            onTap: () => onOpenCarrierUrl(selected.carrierTrackingUrl),
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

class _CarrierInfo extends StatelessWidget {
  const _CarrierInfo({
    required this.label,
    required this.value,
    this.onTap,
    this.primaryColor,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final Color? primaryColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: onTap != null
                          ? (primaryColor ?? colorScheme.primary)
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
                if (onTap != null) ...<Widget>[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: primaryColor ?? colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
