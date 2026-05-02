import 'package:flutter/material.dart';

Future<bool> showConfirmUnlinkProductDialog(
  BuildContext context,
  String productName,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Unlink Product'),
      content: Text('Are you sure you want to unlink "$productName"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.primary,
          ),
          child: const Text('Unlink'),
        ),
      ],
    ),
  );
  return result ?? false;
}
