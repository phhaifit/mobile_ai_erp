import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/product_stock.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/stock_operation.dart';
import 'package:mobile_ai_erp/domain/entity/stock_operations/warehouse.dart';

class WarehouseDropdown extends StatelessWidget {
  const WarehouseDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.warehouses,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<Warehouse> warehouses;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: warehouses
          .map<DropdownMenuItem<String>>(
            (warehouse) => DropdownMenuItem<String>(
              value: warehouse.id,
              child: Text('${warehouse.name} (${warehouse.location})'),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class ProductDropdown extends StatelessWidget {
  const ProductDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.products,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<ProductStock> products;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: products
          .map(
            (stock) => DropdownMenuItem<String>(
              value: stock.productId,
              child: Text('${stock.productName} (${stock.availableQuantity})'),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class DashboardActionCard extends StatelessWidget {
  const DashboardActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon),
                const SizedBox(height: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(subtitle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MobileActionTile extends StatelessWidget {
  const MobileActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class SummaryChip extends StatelessWidget {
  const SummaryChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.secondaryContainer.withValues(alpha: 0.55),
    );
  }
}

class OperationTypeBadge extends StatelessWidget {
  const OperationTypeBadge({super.key, required this.type});

  final StockOperationType type;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;

    switch (type) {
      case StockOperationType.transfer:
        color = Colors.blue.shade100;
        text = 'TRANSFER';
        break;
      case StockOperationType.damaged:
        color = Colors.orange.shade200;
        text = 'DAMAGED';
        break;
      case StockOperationType.expired:
        color = Colors.red.shade200;
        text = 'EXPIRED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

String formatDateTime(DateTime dateTime) {
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.year}-$month-$day $hour:$minute';
}
