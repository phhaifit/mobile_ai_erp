import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute_option.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ProductMetadataAttributeOptionsScreen extends StatefulWidget {
  const ProductMetadataAttributeOptionsScreen({
    super.key,
    required this.args,
  });

  final AttributeOptionsArgs args;

  @override
  State<ProductMetadataAttributeOptionsScreen> createState() =>
      _ProductMetadataAttributeOptionsScreenState();
}

class _ProductMetadataAttributeOptionsScreenState
    extends State<ProductMetadataAttributeOptionsScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await _store.loadDashboard();
      await _store.loadAttributes();
      await _store.loadAttributeOptions(widget.args.attributeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final attribute = _store.findAttributeById(widget.args.attributeId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          attribute == null ? 'Attribute Options' : '${attribute.name} Options',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ProductMetadataNavigator.openAttributeOptionForm(
          context,
          args: AttributeOptionFormArgs(attributeId: widget.args.attributeId),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add option'),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading &&
              _store.activeAttributeId != widget.args.attributeId) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_store.attributeOptions.isEmpty) {
            return const Center(
              child: Text(
                'No options yet. Add the first option to define selectable values.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: _store.attributeOptions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = _store.attributeOptions[index];
              return MetadataListCard(
                title: option.value,
                leading: const Icon(Icons.radio_button_checked_outlined),
                detailLines: _optionSummary(option),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        ProductMetadataNavigator.openAttributeOptionForm(
                          context,
                          args: AttributeOptionFormArgs(
                            attributeId: widget.args.attributeId,
                            attributeOptionId: option.id,
                          ),
                        );
                        break;
                      case 'delete':
                        _deleteOption(option);
                        break;
                    }
                  },
                  itemBuilder: (context) => const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<String> _optionSummary(AttributeOption attributeOption) {
    return <String>[
      'Value: ${attributeOption.value}',
      'Sort order: ${attributeOption.sortOrder}',
    ];
  }

  Future<void> _deleteOption(AttributeOption attributeOption) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete option?'),
              content: Text(
                'Delete "${attributeOption.value}"? This can\'t be undone.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      await _store.deleteAttributeOption(attributeOption.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${attributeOption.value}".')),
      );
    } catch (error) {
      debugPrint('Failed to delete attribute option: $error');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t delete option. Try again.'),
        ),
      );
    }
  }
}

class ProductMetadataAttributeOptionFormScreen extends StatefulWidget {
  const ProductMetadataAttributeOptionFormScreen({
    super.key,
    required this.args,
  });

  final AttributeOptionFormArgs args;

  @override
  State<ProductMetadataAttributeOptionFormScreen> createState() =>
      _ProductMetadataAttributeOptionFormScreenState();
}

class _ProductMetadataAttributeOptionFormScreenState
    extends State<ProductMetadataAttributeOptionFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _valueController;
  late final TextEditingController _sortOrderController;
  bool _isSaving = false;
  String? _valueErrorText;
  AttributeOption? _editingOption;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController();
    _sortOrderController = TextEditingController();
    _valueController.addListener(_clearValueError);
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await _store.loadDashboard();
    await _store.loadAttributes();
    await _store.loadAttributeOptions(widget.args.attributeId);
    _editingOption =
        _store.attributeOptions.cast<AttributeOption?>().firstWhere(
              (option) => option?.id == widget.args.attributeOptionId,
              orElse: () => null,
            );
    if (_editingOption != null) {
      _valueController.text = _editingOption!.value;
      _sortOrderController.text = _editingOption!.sortOrder.toString();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _valueController.removeListener(_clearValueError);
    _valueController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingOption == null ? 'New option' : 'Edit option'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Value',
                  border: const OutlineInputBorder(),
                  errorText: _valueErrorText,
                  errorMaxLines: 3,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Value is required.';
                  }
                  return null;
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
                  _editingOption == null ? 'Create option' : 'Save changes',
                ),
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
      _valueErrorText = null;
    });

    try {
      await _store.saveAttributeOption(
        AttributeOption(
          id: _editingOption?.id ?? '',
          attributeId: widget.args.attributeId,
          value: _valueController.text.trim(),
          sortOrder: int.parse(_sortOrderController.text.trim()),
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
        _valueErrorText = error.message;
      });
    } catch (error) {
      debugPrint('Failed to save attribute option: $error');
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t save option. Try again.'),
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

  void _clearValueError() {
    if (_valueErrorText == null) {
      return;
    }
    setState(() {
      _valueErrorText = null;
    });
  }
}
