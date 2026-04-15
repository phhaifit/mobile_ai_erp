import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/brand_image_api.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_image.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/brands/brand_form_logic.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_active_switch.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_form_decoration.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';

/// Exception thrown when brand image operations fail (upload, delete).
class BrandImageException implements Exception {
  BrandImageException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ProductMetadataBrandFormScreen extends StatefulWidget {
  const ProductMetadataBrandFormScreen({super.key, this.args});

  final BrandFormArgs? args;

  @override
  State<ProductMetadataBrandFormScreen> createState() =>
      _ProductMetadataBrandFormScreenState();
}

class _ProductMetadataBrandFormScreenState
    extends State<ProductMetadataBrandFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final BrandImageApi _brandImageApi = getIt<BrandImageApi>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _logoUrlController = TextEditingController();

  Brand? _editingBrand;
  BrandImage? _currentBrandImage;
  PlatformFile? _pendingLogoFile;
  bool _isActive = true;
  bool _isInitializing = true;
  bool _isSaving = false;
  bool _isUploadingLogo = false;
  bool _removeImageOnSave = false;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_clearNameError);
    Future<void>.microtask(_initialize);
  }

  @override
  void dispose() {
    _nameController.removeListener(_clearNameError);
    _nameController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingBrand == null ? 'New brand' : 'Edit brand'),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: metadataFormDecoration(
                        labelText: 'Name',
                        errorText: _nameErrorText,
                      ),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: metadataFormDecoration(
                        labelText: 'Description',
                      ),
                      minLines: 2,
                      maxLines: 4,
                      validator: _validateDescription,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _logoUrlController,
                      enabled: _pendingLogoFile == null,
                      decoration: metadataFormDecoration(
                        labelText: 'Logo URL',
                        helperText: _pendingLogoFile == null
                            ? 'Use an absolute http/https URL or a local /uploads/... path.'
                            : 'Remove the selected image before editing Logo URL.',
                      ),
                      validator: _validateLogoUrl,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _isSaving || _isUploadingLogo
                          ? null
                          : _chooseBrandImage,
                      icon: _isUploadingLogo
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file_outlined),
                      label: Text(
                        _pendingLogoFile == null
                            ? 'Choose image'
                            : 'Replace selected image',
                      ),
                    ),
                    if (_pendingLogoFile != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        'Selected image: ${_pendingLogoFile!.name}.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ] else ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        _canRemoveCurrentImage
                            ? 'No new image selected. If you replace the current image, it must be JPEG, PNG, or WebP and no larger than 10MB.'
                            : 'Adding an image is optional. If you choose one, it must be JPEG, PNG, or WebP and no larger than 10MB.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (_canRemoveCurrentImage) ...<Widget>[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _isSaving || _isUploadingLogo
                            ? null
                            : _removeCurrentImage,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove current image'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (_editingBrand != null) ...[
                      const SizedBox(height: 16),
                      MetadataActiveSwitch(
                        value: _isActive,
                        resourceLabel: 'brand',
                        onChanged: (value) => setState(() {
                          _isActive = value;
                        }),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isSaving || _isUploadingLogo ? null : _save,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _editingBrand == null ? 'Create brand' : 'Save changes',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  bool get _canRemoveCurrentImage => canRemoveCurrentBrandImage(
    currentBrandImage: _currentBrandImage,
    logoUrl: _logoUrlController.text,
    hasPendingLogoFile: _pendingLogoFile != null,
    removeImageOnSave: _removeImageOnSave,
  );

  Future<void> _initialize() async {
    if (widget.args?.brandId != null) {
      try {
        _editingBrand = await _store.getBrandById(widget.args!.brandId!);
        _currentBrandImage = await _brandImageApi.getBrandImage(
          widget.args!.brandId!,
        );
      } catch (_) {
        _editingBrand = null;
        _currentBrandImage = null;
      }
    }
    if (_editingBrand != null) {
      _nameController.text = _editingBrand!.name;
      _descriptionController.text = _editingBrand!.description ?? '';
      _logoUrlController.text =
          _currentBrandImage?.url ?? _editingBrand!.logoUrl ?? '';
      _isActive = _editingBrand!.isActive;
    }
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _chooseBrandImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );
      final selectedFile = result == null || result.files.isEmpty
          ? null
          : result.files.first;
      if (selectedFile == null || !mounted) {
        return;
      }
      setState(() {
        _pendingLogoFile = selectedFile;
        _removeImageOnSave = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MetadataErrorFormatter.formatActionError(
              error: error,
              actionLabel: 'select brand image',
            ),
          ),
        ),
      );
    }
  }

  void _removeCurrentImage() {
    setState(() {
      _pendingLogoFile = null;
      _currentBrandImage = null;
      _logoUrlController.clear();
      _removeImageOnSave = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _nameErrorText = null;
    });

    try {
      final input = Brand(
        id: _editingBrand?.id ?? '',
        tenantId: _editingBrand?.tenantId ?? '',
        name: _nameController.text.trim(),
        description: _trimOrNull(_descriptionController.text),
        logoUrl: resolveBrandLogoUrlForSave(
          editingBrand: _editingBrand,
          currentBrandImage: _currentBrandImage,
          logoUrl: _logoUrlController.text,
          removeImageOnSave: _removeImageOnSave,
          hasPendingLogoFile: _pendingLogoFile != null,
        ),
        isActive: _isActive,
        createdAt: _editingBrand?.createdAt ?? DateTime.now(),
        updatedAt: _editingBrand?.updatedAt ?? DateTime.now(),
      );
      final savedBrand = _editingBrand == null
          ? await _store.createBrand(input)
          : await _store.updateBrand(input);

      await _syncBrandImage(savedBrand.id);

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on ProductMetadataValidationException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _nameErrorText = error.message;
      });
    } on BrandImageException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MetadataErrorFormatter.formatActionError(
              error: error,
              actionLabel: _editingBrand == null ? 'create brand' : 'save brand',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _syncBrandImage(String brandId) async {
    if (_shouldDeleteBrandImageOnSave) {
      try {
        await _brandImageApi.deleteBrandImage(brandId);
      } catch (error) {
        throw BrandImageException(
          MetadataErrorFormatter.formatActionError(
            error: error,
            actionLabel: 'delete brand image',
          ),
        );
      }
    }
    if (_pendingLogoFile == null) {
      return;
    }

    setState(() {
      _isUploadingLogo = true;
    });
    try {
      final uploaded = await _brandImageApi.uploadBrandImage(
        brandId: brandId,
        file: _pendingLogoFile!,
      );
      _currentBrandImage = uploaded;
      _logoUrlController.text = uploaded.url;
      _pendingLogoFile = null;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingLogo = false;
        });
      }
    }
  }

  bool get _shouldDeleteBrandImageOnSave => shouldDeleteBrandImageOnSave(
    editingBrand: _editingBrand,
    removeImageOnSave: _removeImageOnSave,
    hasPendingLogoFile: _pendingLogoFile != null,
  );

  String? _validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Name is required.';
    }
    if (trimmed.length > 150) {
      return 'Name must be 150 characters or fewer.';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    return (value?.trim().length ?? 0) > 1000
        ? 'Description must be 1000 characters or fewer.'
        : null;
  }

  String? _validateLogoUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.length > 500) {
      return 'Logo URL must be 500 characters or fewer.';
    }
    if (trimmed.startsWith('/uploads/')) {
      return null;
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Enter a valid http/https URL or /uploads/... path.';
    }
    return null;
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _clearNameError() {
    if (_nameErrorText == null) {
      return;
    }
    setState(() {
      _nameErrorText = null;
    });
  }
}
