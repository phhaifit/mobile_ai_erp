import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/units/unit_form_fields.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';

class ProductMetadataUnitFormScreen extends StatefulWidget {
  const ProductMetadataUnitFormScreen({super.key, this.args});

  final UnitFormArgs? args;

  @override
  State<ProductMetadataUnitFormScreen> createState() =>
      _ProductMetadataUnitFormScreenState();
}

class _ProductMetadataUnitFormScreenState
    extends State<ProductMetadataUnitFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Unit? _editingUnit;
  bool _isActive = true;
  bool _isSaving = false;
  bool _isInitializing = true;
  String? _nameErrorText;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_clearNameError);
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    final unitId = widget.args?.unitId;
    if (unitId != null) {
      try {
        _editingUnit = await _store.getUnitById(unitId);
      } catch (_) {
        _editingUnit = null;
      }
    }
    if (_editingUnit != null) {
      _nameController.text = _editingUnit!.name;
      _symbolController.text = _editingUnit!.symbol ?? '';
      _descriptionController.text = _editingUnit!.description ?? '';
      _isActive = _editingUnit!.isActive;
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
    _symbolController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _clearNameError() {
    if (_nameErrorText != null) {
      setState(() {
        _nameErrorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingUnit == null ? 'New unit' : 'Edit unit'),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : UnitFormFields(
              formKey: _formKey,
              nameController: _nameController,
              symbolController: _symbolController,
              descriptionController: _descriptionController,
              isActive: _isActive,
              isSaving: _isSaving,
              nameErrorText: _nameErrorText,
              isEditMode: _editingUnit != null,
              onActiveChanged: (value) => setState(() => _isActive = value),
              onSave: _save,
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
      final unit = Unit(
        id: _editingUnit?.id ?? '',
        tenantId: _editingUnit?.tenantId ?? '',
        name: _nameController.text.trim(),
        symbol: _trimOrNull(_symbolController.text),
        description: _trimOrNull(_descriptionController.text),
        isActive: _isActive,
        createdAt: _editingUnit?.createdAt ?? DateTime.now(),
        updatedAt: _editingUnit?.updatedAt ?? DateTime.now(),
      );
      if (_editingUnit == null) {
        await _store.createUnit(unit);
      } else {
        await _store.updateUnit(unit);
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ProductMetadataValidationException catch (error) {
      setState(() {
        _nameErrorText = error.message;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              MetadataErrorFormatter.formatActionError(
                error: error,
                actionLabel: 'save unit',
              ),
            ),
          ),
        );
      }
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
}
