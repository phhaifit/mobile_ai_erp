import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController _colorHexController = TextEditingController();
  final TextEditingController _sortOrderController = TextEditingController();

  Tag? _editingTag;
  TagStatus _status = TagStatus.active;
  bool _isSaving = false;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_clearNameError);
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await _store.loadDashboard();
    _editingTag = _store.findTagById(widget.args?.tagId);
    if (_editingTag != null) {
      _nameController.text = _editingTag!.name;
      _descriptionController.text = _editingTag!.description ?? '';
      _colorHexController.text = _editingTag!.colorHex ?? '';
      _sortOrderController.text = _editingTag!.sortOrder.toString();
      _status = _editingTag!.status;
    } else {
      _sortOrderController.text = '0';
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_clearNameError);
    _nameController.dispose();
    _descriptionController.dispose();
    _colorHexController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingTag == null ? 'New tag' : 'Edit tag'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: const OutlineInputBorder(),
                  errorText: _nameErrorText,
                  errorMaxLines: 3,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorHexController,
                decoration: const InputDecoration(
                  labelText: 'Color hex',
                  hintText: '#FF6B6B',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TagStatus>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: TagStatus.values
                    .map(
                      (status) => DropdownMenuItem<TagStatus>(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _status = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sortOrderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sort order',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sort order is required.';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Sort order must be a number.';
                  }
                  return null;
                },
              ),
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
      await _store.saveTag(
        Tag(
          id: _editingTag?.id ?? '',
          name: _nameController.text.trim(),
          description: _trimOrNull(_descriptionController.text),
          colorHex: _trimOrNull(_colorHexController.text),
          sortOrder: int.parse(_sortOrderController.text.trim()),
          status: _status,
        ),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } on ProductMetadataValidationException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _nameErrorText = error.message;
      });
    } catch (error) {
      debugPrint('Failed to save tag: $error');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t save tag. Try again.'),
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
