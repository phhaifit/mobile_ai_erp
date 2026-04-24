import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../store/supplier_products_store.dart';

class LinkedProductsHeader extends StatelessWidget {
  const LinkedProductsHeader({
    super.key,
    required this.store,
    required this.onAddProduct,
  });

  final SupplierProductsStore store;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Observer(
          builder: (_) => Row(
            children: [
              Text(
                'Linked Products',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${store.supplierProductsTotalItems}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onAddProduct,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Product'),
        ),
      ],
    );
  }
}
