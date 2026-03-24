import 'package:flutter/material.dart';

/// A horizontal stepper widget for checkout flow
class CheckoutStepperWidget extends StatelessWidget {
  const CheckoutStepperWidget({
    super.key,
    required this.currentStep,
    required this.steps,
    this.onStepTapped,
  });

  final int currentStep;
  final List<CheckoutStepData> steps;
  final ValueChanged<int>? onStepTapped;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              _buildStep(context, i, steps[i]),
              if (i < steps.length - 1) _buildConnector(context, i),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, int index, CheckoutStepData step) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;

    Color backgroundColor;
    Color textColor;
    IconData iconData;

    if (isCompleted) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      iconData = Icons.check;
    } else if (isCurrent) {
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
      iconData = step.icon;
    } else {
      backgroundColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurfaceVariant;
      iconData = step.icon;
    }

    return InkWell(
      onTap: onStepTapped != null && index <= currentStep
          ? () => onStepTapped!(index)
          : null,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                size: 16,
                color: textColor,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              step.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: isCurrent || isCompleted
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isCurrent ? FontWeight.w600 : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnector(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = index < currentStep;

    return Container(
      width: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Divider(
        thickness: 2,
        color: isCompleted ? colorScheme.primary : colorScheme.outlineVariant,
      ),
    );
  }
}

/// Data class for checkout step
class CheckoutStepData {
  const CheckoutStepData({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}
