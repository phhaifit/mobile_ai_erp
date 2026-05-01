import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_values_editor.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/constants/metadata_validation.dart';

class AttributeSetFormBody extends StatelessWidget {
  const AttributeSetFormBody({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.valueFields,
    required this.isSaving,
    required this.isEditing,
    required this.onAddField,
    required this.onRemoveField,
    required this.onReorder,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<AttributeValueField> valueFields;
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onAddField;
  final void Function(int index) onRemoveField;
  final void Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: _validateName,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            validator: (val) => (val?.trim().length ?? 0) > MetadataValidation.attributeSetDescriptionMax
                ? 'Description must be ${MetadataValidation.attributeSetDescriptionMax} characters or fewer.'
                : null,
          ),
          const SizedBox(height: 24),
          AttributeValuesEditor(
            fields: valueFields,
            onAdd: onAddField,
            onRemove: onRemoveField,
            onReorder: onReorder,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isSaving ? null : onSave,
            child: Text(isEditing ? 'Save changes' : 'Create attribute set'),
          ),
        ],
      ),
    );
  }

  String? _validateName(String? val) {
    final t = val?.trim() ?? '';
    if (t.isEmpty) return 'Name is required.';
    if (t.length > MetadataValidation.attributeSetNameMax) {
      return 'Name must be ${MetadataValidation.attributeSetNameMax} characters or fewer.';
    }
    return null;
  }
}
