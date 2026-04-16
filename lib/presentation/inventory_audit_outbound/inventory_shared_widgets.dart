import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/models/inventory_workflow_view_models.dart';

class InventorySectionCard extends StatelessWidget {
  const InventorySectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (trailing == null) {
                  return Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  );
                }

                final isNarrow = constraints.maxWidth < 520;
                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      trailing!,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(child: trailing!),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class DiscrepancyBadge extends StatelessWidget {
  const DiscrepancyBadge({super.key, required this.discrepancy});

  final int discrepancy;

  @override
  Widget build(BuildContext context) {
    final isMismatch = discrepancy != 0;
    final Color color =
        isMismatch ? Colors.red.shade200 : Colors.green.shade200;
    final String text =
        isMismatch ? 'Diff: ${discrepancy > 0 ? '+' : ''}$discrepancy' : 'Match';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class WorkflowStatusBadge extends StatelessWidget {
  const WorkflowStatusBadge.stocktake({
    super.key,
    required StocktakeSessionStatus status,
  })  : stocktakeStatus = status,
        outboundStatus = null;

  const WorkflowStatusBadge.outbound({
    super.key,
    required OutboundIssueStatus status,
  })  : stocktakeStatus = null,
        outboundStatus = status;

  final StocktakeSessionStatus? stocktakeStatus;
  final OutboundIssueStatus? outboundStatus;

  @override
  Widget build(BuildContext context) {
    final statusText = stocktakeStatus != null
        ? _stocktakeLabel(stocktakeStatus!)
        : _outboundLabel(outboundStatus!);
    final colors = stocktakeStatus != null
        ? _stocktakeColors(stocktakeStatus!)
        : _outboundColors(outboundStatus!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: colors.foreground,
        ),
      ),
    );
  }

  String _stocktakeLabel(StocktakeSessionStatus status) {
    switch (status) {
      case StocktakeSessionStatus.draft:
        return 'Draft';
      case StocktakeSessionStatus.counting:
        return 'Counting';
      case StocktakeSessionStatus.submitted:
        return 'Submitted';
      case StocktakeSessionStatus.reconciled:
        return 'Reconciled';
      case StocktakeSessionStatus.approved:
        return 'Approved';
      case StocktakeSessionStatus.rejected:
        return 'Rejected';
    }
  }

  String _outboundLabel(OutboundIssueStatus status) {
    switch (status) {
      case OutboundIssueStatus.draft:
        return 'Draft';
      case OutboundIssueStatus.confirmed:
        return 'Confirmed';
      case OutboundIssueStatus.cancelled:
        return 'Cancelled';
    }
  }

  _StatusColors _stocktakeColors(StocktakeSessionStatus status) {
    switch (status) {
      case StocktakeSessionStatus.approved:
        return _StatusColors(Colors.green.shade100, Colors.green.shade900);
      case StocktakeSessionStatus.rejected:
        return _StatusColors(Colors.red.shade100, Colors.red.shade900);
      case StocktakeSessionStatus.reconciled:
        return _StatusColors(Colors.blue.shade100, Colors.blue.shade900);
      case StocktakeSessionStatus.submitted:
        return _StatusColors(Colors.orange.shade100, Colors.orange.shade900);
      case StocktakeSessionStatus.counting:
        return _StatusColors(Colors.teal.shade100, Colors.teal.shade900);
      case StocktakeSessionStatus.draft:
        return _StatusColors(Colors.grey.shade200, Colors.grey.shade800);
    }
  }

  _StatusColors _outboundColors(OutboundIssueStatus status) {
    switch (status) {
      case OutboundIssueStatus.confirmed:
        return _StatusColors(Colors.green.shade100, Colors.green.shade900);
      case OutboundIssueStatus.cancelled:
        return _StatusColors(Colors.red.shade100, Colors.red.shade900);
      case OutboundIssueStatus.draft:
        return _StatusColors(Colors.grey.shade200, Colors.grey.shade800);
    }
  }
}

class _StatusColors {
  const _StatusColors(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

class WorkflowStepper extends StatelessWidget {
  const WorkflowStepper({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  final List<String> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List<Widget>.generate(steps.length, (index) {
        final isDone = index < currentIndex;
        final isCurrent = index == currentIndex;
        final bg = isDone || isCurrent
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest;
        final fg = isDone || isCurrent
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${index + 1}. ${steps[index]}',
            style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
          ),
        );
      }),
    );
  }
}

class ActionGateItem {
  const ActionGateItem({
    required this.label,
    required this.onPressed,
    required this.enabled,
    this.disabledReason,
    this.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final String? disabledReason;
  final Key? key;
}

class WorkflowActionBar extends StatelessWidget {
  const WorkflowActionBar({
    super.key,
    required this.actions,
  });

  final List<ActionGateItem> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions
          .map(
            (action) => Tooltip(
              message: action.enabled
                  ? action.label
                  : (action.disabledReason ?? 'Action unavailable'),
              child: FilledButton.tonal(
                key: action.key,
                onPressed: action.enabled ? action.onPressed : null,
                child: Text(action.label),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class WarehouseSelector extends StatelessWidget {
  const WarehouseSelector({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label = 'Warehouse',
  });

  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey<String?>(value),
      isExpanded: true,
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

String formatDateTime(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day $hour:$minute';
}



