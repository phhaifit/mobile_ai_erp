import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';

Future<MetadataListQuery?> showUnitFilterSheet(
  BuildContext context,
  MetadataListQuery queryState,
) async {
  final includeInactive = await showModalBottomSheet<bool>(
    context: context,
    builder: (context) {
      var tempValue = queryState.includeInactive;
      return StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Filter units',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  value: tempValue,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Include inactive'),
                  onChanged: (value) => setModalState(() => tempValue = value),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(tempValue),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return includeInactive == null
      ? null
      : queryState.copyWith(includeInactive: includeInactive, page: 1);
}
