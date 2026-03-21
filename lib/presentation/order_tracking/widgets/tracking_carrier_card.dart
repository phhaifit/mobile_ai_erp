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
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor, width: 1),
                foregroundColor: primaryColor,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => onOpenCarrierUrl(selected.carrierTrackingUrl),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(t.translate('tracking_open_carrier_link')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarrierInfo extends StatelessWidget {
  const _CarrierInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: iconColor),
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
