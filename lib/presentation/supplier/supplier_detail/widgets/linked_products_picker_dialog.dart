import 'package:flutter/material.dart';

import '../../../../domain/entity/supplier/product_summary.dart';
import '../../store/supplier_products_store.dart';

Future<void> showLinkedProductsPickerDialog({
  required BuildContext context,
  required SupplierProductsStore store,
  required String supplierId,
  required ProductSummary product,
}) {
  final supplierSkuCtrl = TextEditingController();
  final costPriceCtrl = TextEditingController();
  bool isPrimary = false;

  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('Add Product Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: Theme.of(context).textTheme.bodySmall),
              Text(
                'SKU: ${product.sku}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
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
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await store.addProductToSupplier(
                product.id,
                supplierId,
                supplierSku: supplierSkuCtrl.text.isEmpty
                    ? null
                    : supplierSkuCtrl.text,
                costPrice: costPriceCtrl.text.isEmpty
                    ? null
                    : double.tryParse(costPriceCtrl.text),
                isPrimary: isPrimary,
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Added "${product.name}"'
                        : store.errorMessage ?? 'Failed to add product',
                  ),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ),
  );
}
