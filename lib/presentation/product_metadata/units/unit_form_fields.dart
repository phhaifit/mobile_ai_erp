import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_active_switch.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_form_decoration.dart';

class UnitFormFields extends StatelessWidget {
  const UnitFormFields({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.symbolController,
    required this.descriptionController,
    required this.isActive,
    required this.isSaving,
    required this.nameErrorText,
    required this.isEditMode,
    required this.onActiveChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController symbolController;
  final TextEditingController descriptionController;
  final bool isActive;
  final bool isSaving;
  final String? nameErrorText;
  final bool isEditMode;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: metadataFormDecoration(
                labelText: 'Name',
                errorText: nameErrorText,
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return 'Name is required.';
                if (trimmed.length > 50) return 'Name must be 50 characters or fewer.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: symbolController,
              decoration: metadataFormDecoration(labelText: 'Symbol'),
              validator: (value) => (value?.trim().length ?? 0) > 20
                  ? 'Symbol must be 20 characters or fewer.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: metadataFormDecoration(labelText: 'Description'),
              minLines: 2,
              maxLines: 4,
              validator: (value) => (value?.trim().length ?? 0) > 1000
                  ? 'Description must be 1000 characters or fewer.'
                  : null,
            ),
            const SizedBox(height: 16),
            if (isEditMode) ...[
              const SizedBox(height: 16),
              MetadataActiveSwitch(
                value: isActive,
                resourceLabel: 'unit',
                onChanged: onActiveChanged,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                isEditMode ? 'Save changes' : 'Create unit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
