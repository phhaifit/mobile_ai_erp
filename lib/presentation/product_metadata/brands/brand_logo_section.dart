import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class BrandLogoSection extends StatelessWidget {
  const BrandLogoSection({
    super.key,
    required this.logoUrlController,
    required this.pendingFile,
    required this.canRemove,
    required this.isUploading,
    required this.isSaving,
    required this.onChooseImage,
    required this.onRemoveImage,
    required this.logoUrlValidator,
  });

  final TextEditingController logoUrlController;
  final PlatformFile? pendingFile;
  final bool canRemove;
  final bool isUploading;
  final bool isSaving;
  final VoidCallback onChooseImage;
  final VoidCallback onRemoveImage;
  final String? Function(String?) logoUrlValidator;

  bool get _busy => isSaving || isUploading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          controller: logoUrlController,
          enabled: pendingFile == null,
          decoration: InputDecoration(
            labelText: 'Logo URL',
            helperText: pendingFile == null
                ? 'Use an absolute http/https URL or a local /uploads/... path.'
                : 'Remove the selected image before editing Logo URL.',
            border: const OutlineInputBorder(),
          ),
          validator: logoUrlValidator,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _busy ? null : onChooseImage,
          icon: isUploading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.upload_file_outlined),
          label: Text(pendingFile == null ? 'Choose image' : 'Replace selected image'),
        ),
        const SizedBox(height: 8),
        if (pendingFile != null)
          Text('Selected image: ${pendingFile!.name}.', style: Theme.of(context).textTheme.bodySmall)
        else
          Text(
            canRemove
                ? 'No new image selected. If you replace the current image, it must be JPEG, PNG, or WebP and no larger than 10MB.'
                : 'Adding an image is optional. If you choose one, it must be JPEG, PNG, or WebP and no larger than 10MB.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (canRemove) ...<Widget>[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _busy ? null : onRemoveImage,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove current image'),
          ),
        ],
      ],
    );
  }
}
