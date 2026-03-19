import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:flutter/material.dart';

class ProductMetadataBrandFormScreen extends StatefulWidget {
  const ProductMetadataBrandFormScreen({
    super.key,
    this.args,
  });

  final BrandFormArgs? args;

  @override
  State<ProductMetadataBrandFormScreen> createState() =>
      _ProductMetadataBrandFormScreenState();
}

class _ProductMetadataBrandFormScreenState
    extends State<ProductMetadataBrandFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _logoUrlController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _sortOrderController = TextEditingController();

  Brand? _editingBrand;
  BrandStatus _status = BrandStatus.active;
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
    _editingBrand = _store.findBrandById(widget.args?.brandId);
    if (_editingBrand != null) {
      _nameController.text = _editingBrand!.name;
      _descriptionController.text = _editingBrand!.description ?? '';
      _logoUrlController.text = _editingBrand!.logoUrl ?? '';
      _countryCodeController.text = _editingBrand!.countryCode ?? '';
      _regionController.text = _editingBrand!.regionOrState ?? '';
      _cityController.text = _editingBrand!.city ?? '';
      _sortOrderController.text = _editingBrand!.sortOrder.toString();
      _status = _editingBrand!.status;
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
    _logoUrlController.dispose();
    _countryCodeController.dispose();
    _regionController.dispose();
    _cityController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingBrand == null ? 'New brand' : 'Edit brand'),
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
                controller: _logoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Logo URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _countryCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Country code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(
                  labelText: 'Region / State',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BrandStatus>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: BrandStatus.values
                    .map(
                      (status) => DropdownMenuItem<BrandStatus>(
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
                label: Text(
                    _editingBrand == null ? 'Create brand' : 'Save changes'),
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
      await _store.saveBrand(
        Brand(
          id: _editingBrand?.id ?? '',
          name: _nameController.text.trim(),
          description: _trimOrNull(_descriptionController.text),
          logoUrl: _trimOrNull(_logoUrlController.text),
          countryCode: _trimOrNull(_countryCodeController.text)?.toUpperCase(),
          regionOrState: _trimOrNull(_regionController.text),
          city: _trimOrNull(_cityController.text),
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
      debugPrint('Failed to save brand: $error');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t save brand. Try again.'),
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
