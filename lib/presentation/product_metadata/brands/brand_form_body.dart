import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/brands/brand_logo_section.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_form_decoration.dart';

class BrandFormBody extends StatelessWidget {
  const BrandFormBody({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.logoUrlController,
    required this.nameErrorText,
    required this.pendingLogoFile,
    required this.canRemoveLogo,
    required this.isUploadingLogo,
    required this.isSaving,
    required this.isEditing,
    required this.onChooseImage,
    required this.onRemoveImage,
    required this.onSave,
    required this.validateName,
    required this.validateLogoUrl,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController logoUrlController;
  final String? nameErrorText;
  final PlatformFile? pendingLogoFile;
  final bool canRemoveLogo;
  final bool isUploadingLogo;
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onChooseImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onSave;
  final String? Function(String?) validateName;
  final String? Function(String?) validateLogoUrl;

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
              validator: validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: metadataFormDecoration(labelText: 'Description'),
              minLines: 2,
              maxLines: 4,
              validator: (v) => (v?.trim().length ?? 0) > 1000
                  ? 'Description must be 1000 characters or fewer.'
                  : null,
            ),
            const SizedBox(height: 16),
            BrandLogoSection(
              logoUrlController: logoUrlController,
              pendingFile: pendingLogoFile,
              canRemove: canRemoveLogo,
              isUploading: isUploadingLogo,
              isSaving: isSaving,
              onChooseImage: onChooseImage,
              onRemoveImage: onRemoveImage,
              logoUrlValidator: validateLogoUrl,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: isSaving || isUploadingLogo ? null : onSave,
              icon: isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: Text(isEditing ? 'Save changes' : 'Create brand'),
            ),
          ],
        ),
      ),
    );
  }
}
