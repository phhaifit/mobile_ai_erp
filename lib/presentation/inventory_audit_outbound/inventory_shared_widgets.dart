import 'package:flutter/material.dart';

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
    final Color color = isMismatch ? Colors.red.shade200 : Colors.green.shade200;
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
      isExpanded: true,
      initialValue: value,
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
