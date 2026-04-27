import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';

Future<bool> showAttributeValueDialog(
  BuildContext context, {
  required AttributeSet attributeSet,
  AttributeValue? value,
  required TextEditingController valueController,
  required TextEditingController sortController,
}) async {
  final formKey = GlobalKey<FormState>();
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(value == null ? 'Add value' : 'Edit value'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                  validator: (fieldValue) => _validateValue(
                    fieldValue,
                    attributeSet: attributeSet,
                    editingValue: value,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: sortController,
                  decoration: const InputDecoration(
                    labelText: 'Sort order',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateSortOrder,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ) ??
      false;
}

String? _validateValue(
  String? fieldValue, {
  required AttributeSet attributeSet,
  AttributeValue? editingValue,
}) {
  final trimmed = fieldValue?.trim() ?? '';
  if (trimmed.isEmpty) return 'Value is required.';
  if (trimmed.length > 100) return 'Value must be 100 characters or fewer.';
  final lower = trimmed.toLowerCase();
  final existingValues = attributeSet.values
      .where((v) => editingValue == null || v.id != editingValue.id)
      .map((v) => v.value.toLowerCase())
      .toList();
  if (existingValues.contains(lower)) return 'This value already exists.';
  return null;
}

String? _validateSortOrder(String? fieldValue) {
  if (fieldValue == null || fieldValue.trim().isEmpty) {
    return 'Sort order is required.';
  }
  if (int.tryParse(fieldValue.trim()) == null) return 'Must be a number.';
  return null;
}
