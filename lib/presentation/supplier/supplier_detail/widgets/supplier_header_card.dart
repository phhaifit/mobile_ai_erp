import 'package:flutter/material.dart';
import '../../../../domain/entity/supplier/supplier.dart';

class SupplierHeaderCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback? onDelete;
  const SupplierHeaderCard({
    super.key,
    required this.supplier,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                supplier.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              supplier.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: Text('Delete'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
