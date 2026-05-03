import 'package:flutter/material.dart';

class MetadataSortOption {
  const MetadataSortOption({
    required this.label,
    required this.sortBy,
    required this.sortOrder,
  });

  final String label;
  final String sortBy;
  final String sortOrder;
}

const defaultMetadataSortOption = MetadataSortOption(
  label: 'Default order',
  sortBy: 'name',
  sortOrder: 'asc',
);

Future<void> showMetadataSortSheet(
  BuildContext context, {
  required String title,
  required List<MetadataSortOption> options,
  required void Function(String sortBy, String sortOrder) onSelected,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) => _MetadataSortSheet(
      title: title,
      options: options,
      onSelected: onSelected,
    ),
  );
}

class _MetadataSortSheet extends StatelessWidget {
  const _MetadataSortSheet({
    required this.title,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final List<MetadataSortOption> options;
  final void Function(String sortBy, String sortOrder) onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = options.isEmpty ? defaultMetadataSortOption : options.first;
    final selectedValue = '${selected.sortBy}_${selected.sortOrder}';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            RadioListTile<String>(
              value: selectedValue,
              groupValue: selectedValue,
              contentPadding: EdgeInsets.zero,
              title: Text(selected.label),
              onChanged: (_) {},
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onSelected(selected.sortBy, selected.sortOrder);
                },
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
