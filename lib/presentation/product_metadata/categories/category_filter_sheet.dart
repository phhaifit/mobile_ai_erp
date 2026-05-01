import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';

Future<CategoryStatus?> showCategoryFilterSheet(
  BuildContext context, {
  required CategoryStatus? selectedStatus,
}) async {
  var pendingFilter = CategoryStatusFilter.fromStatus(selectedStatus);
  final selected = await showModalBottomSheet<CategoryStatusFilter>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Filter categories', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Filter by status',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              RadioListTile<CategoryStatusFilter>(
                value: CategoryStatusFilter.all,
                groupValue: pendingFilter,
                contentPadding: EdgeInsets.zero,
                title: const Text('All statuses'),
                onChanged: (value) => setSheetState(() => pendingFilter = value!),
              ),
              RadioListTile<CategoryStatusFilter>(
                value: CategoryStatusFilter.active,
                groupValue: pendingFilter,
                contentPadding: EdgeInsets.zero,
                title: const Text('Active only'),
                onChanged: (value) => setSheetState(() => pendingFilter = value!),
              ),
              RadioListTile<CategoryStatusFilter>(
                value: CategoryStatusFilter.inactive,
                groupValue: pendingFilter,
                contentPadding: EdgeInsets.zero,
                title: const Text('Inactive only'),
                onChanged: (value) => setSheetState(() => pendingFilter = value!),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(pendingFilter),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return (selected ?? CategoryStatusFilter.fromStatus(selectedStatus)).status;
}

enum CategoryStatusFilter {
  all,
  active,
  inactive;

  CategoryStatus? get status => switch (this) {
    CategoryStatusFilter.all => null,
    CategoryStatusFilter.active => CategoryStatus.active,
    CategoryStatusFilter.inactive => CategoryStatus.inactive,
  };

  static CategoryStatusFilter fromStatus(CategoryStatus? status) => switch (status) {
    null => CategoryStatusFilter.all,
    CategoryStatus.active => CategoryStatusFilter.active,
    CategoryStatus.inactive => CategoryStatusFilter.inactive,
  };
}
