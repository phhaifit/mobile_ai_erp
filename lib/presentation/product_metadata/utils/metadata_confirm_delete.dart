import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/logic/metadata_pagination_logic.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';

Future<void> deleteCategoryWithConfirm({
  required BuildContext context,
  required Category category,
  required int currentTotalItems,
  required MetadataListQuery queryState,
  required Future<void> Function(String) deleteFn,
  required void Function(MetadataListQuery) onQueryChanged,
  required Future<void> Function() onReload,
}) async {
  if ((category.childrenCount ?? 0) > 0) {
    await showMetadataDeleteDialog(context,
        title: "Can't delete category",
        message: 'Remove or move the child categories under "${category.name}" first.',
        confirmLabel: 'Got it');
    return;
  }
  if (!await showMetadataDeleteDialog(context,
      title: 'Delete category?',
      message: 'Delete "${category.name}"? This can\'t be undone.')) {
    return;
  }
  await deleteFn(category.id);
  onQueryChanged(queryState.copyWith(
    page: resolveMetadataPageAfterDelete(
      currentPage: queryState.page,
      pageSize: queryState.pageSize,
      totalItems: currentTotalItems,
    ),
  ));
  await onReload();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Deleted "${category.name}".')),
  );
  }
}

/// Shows a generic delete confirmation dialog.
/// Returns `true` if user confirmed, `false`/`null` if cancelled.
Future<bool> showMetadataDeleteDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
