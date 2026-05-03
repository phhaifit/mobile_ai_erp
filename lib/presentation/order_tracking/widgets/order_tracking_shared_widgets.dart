import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Color getOrderStatusColor(String status, ColorScheme colorScheme) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'confirmed':
    case 'packed':
    case 'shipped':
    case 'shipping':
    case 'in_transit':
      return Colors.blue;
    case 'delivered':
      return Colors.green;
    case 'cancelled':
    case 'canceled':
    case 'failed':
      return colorScheme.error;
    default:
      return Colors.grey;
  }
}

String formatOrderPrice(String price, NumberFormat currencyFormat) {
  try {
    final num value = num.parse(price);
    return currencyFormat.format(value.round());
  } catch (_) {
    return price;
  }
}

String formatOrderStatus(String status) {
  final normalized = status.replaceAll('_', ' ').trim();
  if (normalized.isEmpty) return 'Unknown';
  return normalized[0].toUpperCase() + normalized.substring(1);
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.background,
  });

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.alignEnd = false,
    this.valueStyle,
  });

  final String label;
  final String value;
  final bool alignEnd;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueStyle,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
