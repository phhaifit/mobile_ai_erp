import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_set_form_body.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_values_editor.dart';

class ProductMetadataAttributeFormScreen extends StatefulWidget {
  const ProductMetadataAttributeFormScreen({super.key, this.args});
  final AttributeFormArgs? args;
  @override
  State<ProductMetadataAttributeFormScreen> createState() => _ProductMetadataAttributeFormScreenState();
}
class _ProductMetadataAttributeFormScreenState extends State<ProductMetadataAttributeFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<AttributeValueField> _valueFields = [];

  bool _isSaving = false;
  bool _isLoading = false;
  AttributeSet? _editingItem;
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_initialize);
  }
  Future<void> _initialize() async {
    final id = widget.args?.attributeId;
    if (id != null) {
      if (mounted) setState(() => _isLoading = true);
      _editingItem = await _store.getAttributeSetById(id);
      _nameController.text = _editingItem!.name;
      _descriptionController.text = _editingItem!.description ?? '';
      final sorted = [..._editingItem!.values]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      for (final val in sorted) {
        _valueFields.add(AttributeValueField(id: val.id, initialText: val.value, sortOrder: val.sortOrder));
      }
      if (mounted) setState(() => _isLoading = false);
    } else {
      _addField();
    }
  }
  void _addField() => setState(() => _valueFields.add(AttributeValueField(initialText: '', sortOrder: _valueFields.length)));
  void _removeField(int i) => setState(() { _valueFields[i].dispose(); _valueFields.removeAt(i); });
  void _reorder(int oldIdx, int newIdx) {
    setState(() {
      if (oldIdx < newIdx) newIdx -= 1;
      final item = _valueFields.removeAt(oldIdx);
      _valueFields.insert(newIdx, item);
      for (int i = 0; i < _valueFields.length; i++) {
        _valueFields[i].sortOrderController.text = i.toString();
      }
    });
  }
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final f in _valueFields) {
      f.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editingItem == null ? 'New attribute set' : 'Edit attribute set')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AttributeSetFormBody(formKey: _formKey, nameController: _nameController, descriptionController: _descriptionController, valueFields: _valueFields, isSaving: _isSaving, isEditing: _editingItem != null, onAddField: _addField, onRemoveField: _removeField, onReorder: _reorder, onSave: _save),
    );
  }
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final values = _valueFields.asMap().entries.where((e) => e.value.controller.text.trim().isNotEmpty).map((e) => AttributeValue(id: e.value.id, attributeSetId: _editingItem?.id ?? '', value: e.value.controller.text.trim(), sortOrder: int.tryParse(e.value.sortOrderController.text.trim()) ?? e.key, createdAt: _editingItem?.createdAt ?? DateTime.now())).toList();
    final item = AttributeSet(id: _editingItem?.id ?? '', tenantId: _editingItem?.tenantId ?? '', name: _nameController.text.trim(), description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(), createdAt: _editingItem?.createdAt ?? DateTime.now(), updatedAt: _editingItem?.updatedAt ?? DateTime.now(), values: values);
    try {
      if (_editingItem == null) { await _store.createAttributeSet(item); } else { await _store.updateAttributeSet(item); }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(MetadataErrorFormatter.formatActionError(
          error: error,
          actionLabel: _editingItem == null ? 'create attribute set' : 'save attribute set',
        )),
      ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
