import 'package:flutter/material.dart';
import 'supplier_list_models.dart';

class SupplierFilterSheetResult {
  const SupplierFilterSheetResult({
    required this.productsFilter,
  });

  final SupplierProductsFilter productsFilter;

  bool? get hasProducts => productsFilter.hasProductsValue;
}

Future<SupplierFilterSheetResult?> showSupplierFilterSheet(
  BuildContext context, {
  required SupplierProductsFilter current,
}) {
  return showModalBottomSheet<SupplierFilterSheetResult>(
    context: context,
    builder: (context) {
      var selected = current;
      return StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filter suppliers',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...SupplierProductsFilter.values.map(
                  (option) => RadioListTile<SupplierProductsFilter>(
                    value: option,
                    groupValue: selected,
                    contentPadding: EdgeInsets.zero,
                    title: Text(option.label),
                    onChanged: (value) =>
                        setModalState(() => selected = value!),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(
                    SupplierFilterSheetResult(productsFilter: selected),
                  ),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
