import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';

class _ValueField {
  _ValueField({this.id = '', required String initialText, int sortOrder = 0})
      : controller = TextEditingController(text: initialText),
        sortOrderController = TextEditingController(text: sortOrder.toString());
  final String id;
  final TextEditingController controller;
  final TextEditingController sortOrderController;

  void dispose() {
    controller.dispose();
    sortOrderController.dispose();
  }
}

class ProductMetadataAttributeFormScreen extends StatefulWidget {
  const ProductMetadataAttributeFormScreen({super.key, this.args});

  final AttributeFormArgs? args;

  @override
  State<ProductMetadataAttributeFormScreen> createState() =>
      _ProductMetadataAttributeFormScreenState();
}

class _ProductMetadataAttributeFormScreenState
    extends State<ProductMetadataAttributeFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  final List<_ValueField> _valueFields = [];
  bool _isSaving = false;
  bool _isLoading = false;
  AttributeSet? _editingItem;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    final attributeSetId = widget.args?.attributeId;
    if (attributeSetId != null) {
      if (mounted) setState(() => _isLoading = true);
      _editingItem = await _store.getAttributeSetById(attributeSetId);
      _nameController.text = _editingItem!.name;
      _descriptionController.text = _editingItem!.description ?? '';
      
      final sortedValues = [..._editingItem!.values]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      
      for (final val in sortedValues) {
        _valueFields.add(_ValueField(
          id: val.id,
          initialText: val.value,
          sortOrder: val.sortOrder,
        ));
      }
      if (mounted) setState(() => _isLoading = false);
    } else {
      _addValueField();
    }
  }

  void _addValueField() {
    setState(() {
      _valueFields.add(_ValueField(initialText: '', sortOrder: _valueFields.length));
    });
  }

  void _removeValueField(int index) {
    setState(() {
      _valueFields[index].dispose();
      _valueFields.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var field in _valueFields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingItem == null ? 'New attribute set' : 'Edit attribute set'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value?.trim().isEmpty ?? true) ? 'Name is required.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Values',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton.icon(
                        onPressed: _addValueField,
                        icon: const Icon(Icons.add),
                        label: const Text('Add value'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_valueFields.isNotEmpty)
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      buildDefaultDragHandles: false,
                      clipBehavior: Clip.none,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _valueFields.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = _valueFields.removeAt(oldIndex);
                          _valueFields.insert(newIndex, item);

                          // Update sort order values to reflect the new positions
                          for (int i = 0; i < _valueFields.length; i++) {
                            _valueFields[i].sortOrderController.text = i.toString();
                          }
                        });
                      },
                      itemBuilder: (context, index) {
                        final field = _valueFields[index];
                        return Padding(
                          key: ValueKey(field),
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: ReorderableDragStartListener(
                                  index: index,
                                  child: const MouseRegion(
                                    cursor: SystemMouseCursors.grab,
                                    child: Icon(Icons.drag_indicator, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: field.controller,
                                  decoration: const InputDecoration(
                                    labelText: 'Value',
                                    hintText: 'e.g. Red',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    final text = value.trim().toLowerCase();
                                    final allValues = _valueFields
                                        .map((c) => c.controller.text.trim().toLowerCase())
                                        .where((v) => v.isNotEmpty)
                                        .toList();
                                    if (allValues.where((v) => v == text).length > 1) {
                                      return 'Duplicate value.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  controller: field.sortOrderController,
                                  decoration: const InputDecoration(
                                    labelText: 'Sort',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Required';
                                    }
                                    if (int.tryParse(value.trim()) == null) {
                                      return 'Must be a number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  color: Colors.red,
                                  onPressed: () => _removeValueField(index),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  if (_valueFields.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('No values added yet.'),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: Text(_editingItem == null ? 'Create attribute set' : 'Save changes'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    
    // Filter out empty values and preserve IDs for existing values
    final values = _valueFields
        .asMap()
        .entries
        .where((entry) => entry.value.controller.text.trim().isNotEmpty)
        .map((entry) {
            final index = entry.key;
            final field = entry.value;
            return AttributeValue(
              id: field.id,
              attributeSetId: _editingItem?.id ?? '',
              value: field.controller.text.trim(),
              sortOrder: int.tryParse(field.sortOrderController.text.trim()) ?? index,
              createdAt: _editingItem?.createdAt ?? DateTime.now(),
            );
        })
        .toList();

    final item = AttributeSet(
      id: _editingItem?.id ?? '',
      tenantId: _editingItem?.tenantId ?? '', // TODO: Use actual tenant ID from auth context/current user's session
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      createdAt: _editingItem?.createdAt ?? DateTime.now(),
      values: values,
    );
    try {
      if (_editingItem == null) {
        await _store.createAttributeSet(item);
      } else {
        await _store.updateAttributeSet(item);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              MetadataErrorFormatter.formatActionError(
                error: error,
                actionLabel: _editingItem == null
                    ? 'create attribute set'
                    : 'save attribute set',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
