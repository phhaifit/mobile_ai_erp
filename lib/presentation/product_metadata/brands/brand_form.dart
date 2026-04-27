import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_image.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/get_brand_image_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/upload_brand_image_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/delete_brand_image_usecase.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/brands/brand_form_body.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/brands/brand_form_logic.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';

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
  State<ProductMetadataBrandFormScreen> createState() => _ProductMetadataBrandFormScreenState();
}
class _ProductMetadataBrandFormScreenState extends State<ProductMetadataBrandFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GetBrandImageUseCase _getBrandImage = getIt<GetBrandImageUseCase>();
  final UploadBrandImageUseCase _uploadBrandImage = getIt<UploadBrandImageUseCase>();
  final DeleteBrandImageUseCase _deleteBrandImage = getIt<DeleteBrandImageUseCase>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _logoUrlController = TextEditingController();

  Brand? _editingBrand;
  BrandImage? _currentBrandImage;
  PlatformFile? _pendingLogoFile;
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
      appBar: AppBar(title: Text(_editingBrand == null ? 'New brand' : 'Edit brand')),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : BrandFormBody(formKey: _formKey, nameController: _nameController, descriptionController: _descriptionController, logoUrlController: _logoUrlController, nameErrorText: _nameErrorText, pendingLogoFile: _pendingLogoFile, canRemoveLogo: _canRemoveCurrentImage, isUploadingLogo: _isUploadingLogo, isSaving: _isSaving, isEditing: _editingBrand != null, onChooseImage: _chooseBrandImage, onRemoveImage: _removeCurrentImage, onSave: _save, validateName: _validateName, validateLogoUrl: _validateLogoUrl),
    );
  }

  bool get _canRemoveCurrentImage => canRemoveCurrentBrandImage(currentBrandImage: _currentBrandImage, logoUrl: _logoUrlController.text, hasPendingLogoFile: _pendingLogoFile != null, removeImageOnSave: _removeImageOnSave);

  Future<void> _initialize() async {
    if (widget.args?.brandId != null) {
      try {
        _editingBrand = await _store.getBrandById(widget.args!.brandId!);
        _currentBrandImage = await _getBrandImage.call(params: widget.args!.brandId!);
      } catch (_) {
        _editingBrand = null;
        _currentBrandImage = null;
      }
    }
    if (_editingBrand != null) {
      _nameController.text = _editingBrand!.name;
      _descriptionController.text = _editingBrand!.description ?? '';
      _logoUrlController.text = _currentBrandImage?.url ?? _editingBrand!.logoUrl ?? '';
    }
    if (mounted) setState(() => _isInitializing = false);
  }

  Future<void> _chooseBrandImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false, withData: true);
      final file = result?.files.firstOrNull;
      if (file == null || !mounted) return;
      setState(() { _pendingLogoFile = file; _removeImageOnSave = false; });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(MetadataErrorFormatter.formatActionError(error: error, actionLabel: 'select brand image'))));
    }
  }

  void _removeCurrentImage() => setState(() {
    _pendingLogoFile = null;
    _currentBrandImage = null;
    _logoUrlController.clear();
    _removeImageOnSave = true;
  });

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; _nameErrorText = null; });
    try {
      final input = Brand(id: _editingBrand?.id ?? '', tenantId: _editingBrand?.tenantId ?? '', name: _nameController.text.trim(), description: _trimOrNull(_descriptionController.text), logoUrl: resolveBrandLogoUrlForSave(editingBrand: _editingBrand, currentBrandImage: _currentBrandImage, logoUrl: _logoUrlController.text, removeImageOnSave: _removeImageOnSave, hasPendingLogoFile: _pendingLogoFile != null), createdAt: _editingBrand?.createdAt ?? DateTime.now(), updatedAt: _editingBrand?.updatedAt ?? DateTime.now());
      final saved = _editingBrand == null ? await _store.createBrand(input) : await _store.updateBrand(input);
      await _syncBrandImage(saved.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ProductMetadataValidationException catch (e) {
      if (!mounted) return;
      setState(() { _isSaving = false; _nameErrorText = e.message; });
    } on BrandImageException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(MetadataErrorFormatter.formatActionError(error: e, actionLabel: _editingBrand == null ? 'create brand' : 'save brand'))));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _syncBrandImage(String brandId) async {
    if (shouldDeleteBrandImageOnSave(editingBrand: _editingBrand, removeImageOnSave: _removeImageOnSave, hasPendingLogoFile: _pendingLogoFile != null)) {
      try {
        await _deleteBrandImage.call(params: brandId);
      } catch (e) {
        throw BrandImageException(MetadataErrorFormatter.formatActionError(error: e, actionLabel: 'delete brand image'));
      }
    }
    if (_pendingLogoFile == null) return;
    setState(() => _isUploadingLogo = true);
    try {
      final uploaded = await _uploadBrandImage.call(params: UploadBrandImageParams(brandId: brandId, file: _pendingLogoFile!));
      _currentBrandImage = uploaded;
      _logoUrlController.text = uploaded.url;
      _pendingLogoFile = null;
    } finally {
      if (mounted) setState(() => _isUploadingLogo = false);
    }
  }

  String? _validateName(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Name is required.';
    if (t.length > 150) return 'Name must be 150 characters or fewer.';
    return null;
  }

  String? _validateLogoUrl(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    if (t.length > 500) return 'Logo URL must be 500 characters or fewer.';
    if (t.startsWith('/uploads/')) return null;
    final uri = Uri.tryParse(t);
    if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return 'Enter a valid http/https URL or /uploads/... path.';
    }
    return null;
  }

  String? _trimOrNull(String v) { final t = v.trim(); return t.isEmpty ? null : t; }
  void _clearNameError() { if (_nameErrorText != null) setState(() => _nameErrorText = null); }
}
