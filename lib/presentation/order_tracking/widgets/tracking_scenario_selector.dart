import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';

class TrackingScenarioSelector extends StatelessWidget {
  const TrackingScenarioSelector({
    super.key,
    required this.isCompact,
    required this.scenarios,
    required this.selected,
    required this.primaryColor,
    required this.onChanged,
  });

  final bool isCompact;
  final List<OrderTrackingScenario> scenarios;
  final OrderTrackingScenario selected;
  final Color primaryColor;
  final ValueChanged<OrderTrackingScenario> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final bool hasSelected = scenarios.any(
      (OrderTrackingScenario item) => item.orderId == selected.orderId,
    );
    final OrderTrackingScenario? dropdownValue = hasSelected ? selected : null;

    return _SectionCard(
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SectionTitle(
                  title: t.translate('tracking_scenario_label'),
                  icon: Icons.tune_rounded,
                  iconColor: primaryColor,
                ),
                const SizedBox(height: 12),
                _ScenarioDropdown(
                  scenarios: scenarios,
                  selected: dropdownValue,
                  onChanged: onChanged,
                ),
              ],
            )
          : Row(
              children: <Widget>[
                Expanded(
                  child: _SectionTitle(
                    title: t.translate('tracking_scenario_label'),
                    icon: Icons.tune_rounded,
                    iconColor: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScenarioDropdown(
                    scenarios: scenarios,
                    selected: dropdownValue,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ScenarioDropdown extends StatelessWidget {
  const _ScenarioDropdown({
    required this.scenarios,
    required this.selected,
    required this.onChanged,
  });

  final List<OrderTrackingScenario> scenarios;
  final OrderTrackingScenario? selected;
  final ValueChanged<OrderTrackingScenario> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.12)),
      ),
      child: DropdownButton<OrderTrackingScenario>(
        isExpanded: true,
        underline: const SizedBox.shrink(),
        value: selected,
        items: scenarios
            .map(
              (OrderTrackingScenario item) =>
                  DropdownMenuItem<OrderTrackingScenario>(
                value: item,
                child: Text(item.scenarioName),
              ),
            )
            .toList(),
        onChanged: (OrderTrackingScenario? data) {
          if (data != null) {
            onChanged(data);
          }
        },
      ),
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
        border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.12), width: 1),
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
