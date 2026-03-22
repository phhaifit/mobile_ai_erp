import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/order_tracking/order_tracking_scenario.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/widgets/tracking_shared_section.dart';

class TrackingScenarioSelector extends StatelessWidget {
  const TrackingScenarioSelector({
    super.key,
    required this.isCompact,
    required this.scenarios,
    required this.selected,
    required this.primaryColor,
    required this.onChanged,
    required this.scenarioLabel,
  });

  final bool isCompact;
  final List<OrderTrackingScenario> scenarios;
  final OrderTrackingScenario selected;
  final Color primaryColor;
  final ValueChanged<OrderTrackingScenario> onChanged;
  final String scenarioLabel;

  @override
  Widget build(BuildContext context) {
    final bool hasSelected = scenarios.any(
      (OrderTrackingScenario item) => item.orderId == selected.orderId,
    );
    final OrderTrackingScenario? dropdownValue = hasSelected ? selected : null;

    return TrackingSectionCard(
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TrackingSectionTitle(
                  title: scenarioLabel,
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
                  child: TrackingSectionTitle(
                    title: scenarioLabel,
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
        border:
            Border.all(color: colorScheme.onSurface.withValues(alpha: 0.12)),
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
