import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';

class TrackingCarrierCard extends StatelessWidget {
  const TrackingCarrierCard({
    super.key,
    required this.selected,
    required this.primaryColor,
    required this.onOpenCarrierUrl,
  });

  final OrderTrackingScenario selected;
  final Color primaryColor;
  final ValueChanged<String> onOpenCarrierUrl;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionTitle(
            title: t.translate('tracking_carrier_section_title'),
            icon: Icons.local_shipping_outlined,
            iconColor: primaryColor,
          ),
          const SizedBox(height: 14),
          _CarrierInfo(
            label: '${t.translate('tracking_carrier_name_label')}:',
            value: selected.carrierName,
          ),
          const SizedBox(height: 10),
          _CarrierInfo(
            label: '${t.translate('tracking_number_label')}:',
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
