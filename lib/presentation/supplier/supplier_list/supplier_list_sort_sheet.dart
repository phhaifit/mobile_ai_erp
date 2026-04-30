import 'package:flutter/material.dart';

import 'supplier_list_models.dart';

Future<SupplierSortOption?> showSupplierSortSheet(
  BuildContext context, {
  required SupplierSortOption currentSort,
}) {
  return showModalBottomSheet<SupplierSortOption>(
    context: context,
    builder: (context) {
      var tempSort = currentSort;
      return StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sort suppliers', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                for (final option in SupplierSortOption.values)
                  RadioListTile<SupplierSortOption>(
                    value: option,
                    groupValue: tempSort,
                    contentPadding: EdgeInsets.zero,
                    title: Text(option.label),
                    onChanged: (value) => setModalState(() => tempSort = value!),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(tempSort),
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
