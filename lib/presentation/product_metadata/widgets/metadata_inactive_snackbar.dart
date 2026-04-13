import 'package:flutter/material.dart';

/// A reusable snackbar widget for metadata that is inactive/archived
/// Usage: showMetadataInactiveSnackbar(context, itemType: 'Brand')
void showMetadataInactiveSnackbar(
  BuildContext context, {
  required String itemType,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'This $itemType is inactive and cannot be edited.',
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}
