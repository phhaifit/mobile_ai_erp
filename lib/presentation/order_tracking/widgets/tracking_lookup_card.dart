import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';

class TrackingLookupCard extends StatelessWidget {
  const TrackingLookupCard({
    super.key,
    required this.orderIdController,
    required this.tokenController,
    required this.primaryColor,
    required this.onLookup,
  });

  final TextEditingController orderIdController;
  final TextEditingController tokenController;
  final Color primaryColor;
  final VoidCallback onLookup;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionTitle(
            title: t.translate('tracking_lookup_title'),
            icon: Icons.search_rounded,
            iconColor: primaryColor,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: orderIdController,
            decoration: _inputDecoration(
              label: t.translate('tracking_order_id_label'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: tokenController,
            decoration: _inputDecoration(
              label: t.translate('tracking_token_label'),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onLookup,
              icon: const Icon(Icons.travel_explore_outlined, size: 20),
              label: Text(t.translate('tracking_lookup_button')),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
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
