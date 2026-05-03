import 'package:flutter/material.dart';

import '../../../../domain/entity/supplier/supplier_product_link.dart';
import '../../store/supplier_products_store.dart';

Future<void> showLinkedProductsEditDialog({
  required BuildContext context,
  required SupplierProductsStore store,
  required SupplierProductLink link,
}) {
  final supplierSkuCtrl = TextEditingController(text: link.supplierSku ?? '');
  final costPriceCtrl = TextEditingController(
    text: link.costPrice != null ? link.costPrice!.toStringAsFixed(2) : '',
  );
  bool isPrimary = link.isPrimary;

  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('Edit Product Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(link.productName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            if (link.productSku != null)
              Text(
                link.productSku!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: supplierSkuCtrl,
              decoration: const InputDecoration(
                labelText: 'Supplier SKU (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: costPriceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cost Price (Optional)',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: isPrimary,
              onChanged: (value) => setState(() => isPrimary = value ?? false),
              title: const Text('Set as Primary Supplier'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await store.updateProductSupplierLink(
                link.productId,
                link.supplierId,
                supplierSku: supplierSkuCtrl.text.isEmpty ? null : supplierSkuCtrl.text,
                costPrice: costPriceCtrl.text.isEmpty ? null : double.tryParse(costPriceCtrl.text),
                isPrimary: isPrimary,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Updated "${link.productName}"'
                        : store.errorMessage ?? 'Failed to update link',
                  ),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
