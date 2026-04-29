import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_parent_dropdown.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/constants/metadata_validation.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_form_decoration.dart';

class CategoryFormBody extends StatelessWidget {
  const CategoryFormBody({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.slugController,
    required this.descriptionController,
    required this.parentOptions,
    required this.selectedParentId,
    required this.status,
    required this.isSaving,
    required this.isEditing,
    required this.onParentChanged,
    required this.onStatusChanged,
    required this.onSave,
    required this.validateSlug,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController slugController;
  final TextEditingController descriptionController;
  final List<Category> parentOptions;
  final String? selectedParentId;
  final CategoryStatus status;
  final bool isSaving;
  final bool isEditing;
  final ValueChanged<String?> onParentChanged;
  final ValueChanged<CategoryStatus> onStatusChanged;
  final VoidCallback onSave;
  final String? Function(String) validateSlug;

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
              decoration: metadataFormDecoration(labelText: 'Name'),
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: slugController,
              decoration: metadataFormDecoration(
                labelText: 'Slug',
                helperText: 'Lowercase letters, numbers, and hyphens only.',
              ),
              validator: _validateSlugField,
            ),
            const SizedBox(height: 16),
            CategoryParentDropdown(
              categories: parentOptions,
              selectedParentId: selectedParentId,
              onChanged: onParentChanged,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: metadataFormDecoration(labelText: 'Description'),
              minLines: 2,
              maxLines: 4,
              validator: (val) => (val?.trim().length ?? 0) > MetadataValidation.categoryDescriptionMax
                  ? 'Description must be ${MetadataValidation.categoryDescriptionMax} characters or fewer.'
                  : null,
            ),
            const SizedBox(height: 16),
            _StatusRow(status: status, onChanged: onStatusChanged),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: Text(isEditing ? 'Save changes' : 'Create category'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateName(String? val) {
    final t = val?.trim() ?? '';
    if (t.isEmpty) return 'Name is required.';
    if (t.length > MetadataValidation.categoryNameMax) {
      return 'Name must be ${MetadataValidation.categoryNameMax} characters or fewer.';
    }
    return null;
  }

  String? _validateSlugField(String? val) {
    final t = val?.trim() ?? '';
    if (t.isEmpty) return 'Slug is required.';
    if (t.length > MetadataValidation.categorySlugMax) {
      return 'Slug must be ${MetadataValidation.categorySlugMax} characters or fewer.';
    }
    return validateSlug(t);
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.status, required this.onChanged});

  final CategoryStatus status;
  final ValueChanged<CategoryStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text('Status', style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        SegmentedButton<CategoryStatus>(
          segments: const <ButtonSegment<CategoryStatus>>[
            ButtonSegment(value: CategoryStatus.active, label: Text('Active')),
            ButtonSegment(value: CategoryStatus.inactive, label: Text('Inactive')),
          ],
          selected: {status},
          onSelectionChanged: (s) => onChanged(s.first),
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
        ),
      ],
    );
  }
}
