import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';

class CategoryStatusChip extends StatelessWidget {
  const CategoryStatusChip({super.key, required this.status});

  final CategoryStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = status == CategoryStatus.active;
    return MetadataStatusChip(
      label: isActive ? 'Active' : 'Inactive',
      backgroundColor: isActive
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerHighest,
      foregroundColor: isActive
          ? colorScheme.onSecondaryContainer
          : colorScheme.onSurfaceVariant,
    );
  }
}
