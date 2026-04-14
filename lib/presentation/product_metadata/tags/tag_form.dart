import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_active_switch.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_form_decoration.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';

class ProductMetadataTagFormScreen extends StatefulWidget {
  const ProductMetadataTagFormScreen({
    super.key,
    this.args,
  });

  final TagFormArgs? args;

  @override
  State<ProductMetadataTagFormScreen> createState() =>
      _ProductMetadataTagFormScreenState();
}

class _ProductMetadataTagFormScreenState
    extends State<ProductMetadataTagFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Tag? _editingTag;
  bool _isActive = true;
  bool _isInitializing = true;
  bool _isSaving = false;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_clearNameError);
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    if (widget.args?.tagId != null) {
      try {
        _editingTag = await _store.getTagById(widget.args!.tagId!);
      } catch (_) {
        _editingTag = null;
      }
    }
    if (_editingTag != null) {
      _nameController.text = _editingTag!.name;
      _descriptionController.text = _editingTag!.description ?? '';
      _isActive = _editingTag!.isActive;
    }
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_clearNameError);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingTag == null ? 'New tag' : 'Edit tag'),
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
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Name is required.';
                  }
                  if (trimmed.length > 100) {
                    return 'Name must be 100 characters or fewer.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: metadataFormDecoration(
                  labelText: 'Description',
                ),
                minLines: 2,
                maxLines: 4,
                validator: (value) {
                  if ((value?.trim().length ?? 0) > 1000) {
                    return 'Description must be 1000 characters or fewer.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_editingTag != null) ...[
                const SizedBox(height: 16),
                MetadataActiveSwitch(
                  value: _isActive,
                  resourceLabel: 'tag',
                  onChanged: (value) => setState(() {
                    _isActive = value;
                  }),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label:
                    Text(_editingTag == null ? 'Create tag' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
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
      final input = Tag(
        id: _editingTag?.id ?? '',
        tenantId: _editingTag?.tenantId ?? '', // TODO: Use actual tenant ID from auth context/current user's session
        name: _nameController.text.trim(),
        description: _trimOrNull(_descriptionController.text),
        isActive: _isActive,
        createdAt: _editingTag?.createdAt ?? DateTime.now(),
        updatedAt: _editingTag?.updatedAt ?? DateTime.now(),
      );

      if (_editingTag == null) {
        await _store.createTag(input);
      } else {
        await _store.updateTag(input);
      }

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
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MetadataErrorFormatter.formatActionError(
              error: error,
              actionLabel: _editingTag == null ? 'create tag' : 'save tag',
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
