import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_relationships_tab.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ProductMetadataAttributesScreen extends StatefulWidget {
  const ProductMetadataAttributesScreen({
    super.key,
    this.args = const AttributesArgs(),
  });

  final AttributesArgs args;

  @override
  State<ProductMetadataAttributesScreen> createState() =>
      _ProductMetadataAttributesScreenState();
}

class _ProductMetadataAttributesScreenState
    extends State<ProductMetadataAttributesScreen>
    with SingleTickerProviderStateMixin {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  late final TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (_currentTabIndex != _tabController.index && mounted) {
          setState(() {
            _currentTabIndex = _tabController.index;
          });
        }
      });
    Future<void>.microtask(() async {
      await _store.loadDashboard();
      await _store.loadAttributes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attributes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Tab>[
            Tab(text: 'List'),
            Tab(text: 'Relationships'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _currentTabIndex == 0
            ? () => ProductMetadataNavigator.openAttributeForm(context)
            : (_store.categories.isNotEmpty && _store.attributes.isNotEmpty)
                ? () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const ProductMetadataCategoryRelationshipFormScreen(),
                      ),
                    )
                : null,
        icon: Icon(
          _currentTabIndex == 0 ? Icons.add : Icons.add_link_outlined,
        ),
        label: Text(
          _currentTabIndex == 0 ? 'Add attribute' : 'Add relationship',
        ),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && !_store.hasLoadedDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: <Widget>[
              _AttributesListTab(store: _store),
              AttributeRelationshipsTab(store: _store),
            ],
          );
        },
      ),
    );
  }
}

class _AttributesListTab extends StatelessWidget {
  const _AttributesListTab({required this.store});

  final ProductMetadataStore store;

  @override
  Widget build(BuildContext context) {
    if (store.attributes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.tune_outlined,
                        size: 28,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No attributes yet',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add the first attribute to define reusable product metadata.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemBuilder: (context, index) {
        final attribute = store.attributes[index];
        return MetadataListCard(
          title: attribute.name,
          leading: const Icon(Icons.label_outline),
          detailLines: _attributeSummary(
            attribute,
            store.optionCountForAttribute(attribute.id),
          ),
          chips: <Widget>[
            MetadataStatusChip(label: attribute.valueType.label),
            if (attribute.isFilterable)
              const MetadataStatusChip(label: 'Filterable'),
          ],
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'options':
                  ProductMetadataNavigator.openAttributeOptions(
                    context,
                    args: AttributeOptionsArgs(attributeId: attribute.id),
                  );
                  break;
                case 'edit':
                  ProductMetadataNavigator.openAttributeForm(
                    context,
                    args: AttributeFormArgs(attributeId: attribute.id),
                  );
                  break;
                case 'delete':
                  _deleteAttribute(context, store, attribute);
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              if (attribute.valueType.supportsOptions)
                const PopupMenuItem<String>(
                  value: 'options',
                  child: Text('Manage options'),
                ),
              const PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
          onTap: () => ProductMetadataNavigator.openAttributeDetail(
            context,
            args: AttributeDetailArgs(attributeId: attribute.id),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: store.attributes.length,
    );
  }

  List<String> _attributeSummary(Attribute attribute, int optionCount) {
    return <String>[
      'Code: ${attribute.code}',
      'Type: ${attribute.valueType.label}',
      if (attribute.valueType.supportsOptions) 'Options: $optionCount',
      if (attribute.effectiveUnitLabels.isNotEmpty)
        'Units: ${attribute.effectiveUnitLabels.join(', ')}',
      if (attribute.valueType == AttributeValueType.text &&
          attribute.maxLength != null)
        'Max length: ${attribute.maxLength}',
      if (attribute.valueType == AttributeValueType.number &&
          attribute.maxValue != null)
        'Max value: ${attribute.maxValue}',
    ];
  }

  Future<void> _deleteAttribute(
    BuildContext context,
    ProductMetadataStore store,
    Attribute attribute,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete attribute?'),
              content: Text(
                'Delete "${attribute.name}"? This can\'t be undone.',
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
      await store.deleteAttribute(attribute.id);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${attribute.name}".')),
      );
    } catch (error) {
      debugPrint('Failed to delete attribute: $error');
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t delete attribute. Try again.'),
        ),
      );
    }
  }
}

class ProductMetadataAttributeFormScreen extends StatefulWidget {
  const ProductMetadataAttributeFormScreen({
    super.key,
    this.args = const AttributeFormArgs(),
  });

  final AttributeFormArgs args;

  @override
  State<ProductMetadataAttributeFormScreen> createState() =>
      _ProductMetadataAttributeFormScreenState();
}

class _ProductMetadataAttributeFormScreenState
    extends State<ProductMetadataAttributeFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _minLengthController;
  late final TextEditingController _maxLengthController;
  late final TextEditingController _inputPatternController;
  late final TextEditingController _minValueController;
  late final TextEditingController _maxValueController;
  late final TextEditingController _decimalPlacesController;
  late final TextEditingController _allowedUnitsController;
  AttributeValueType _valueType = AttributeValueType.dropdown;
  bool _isFilterable = true;
  bool _isSaving = false;
  String? _nameErrorText;
  Attribute? _editingAttribute;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _sortOrderController = TextEditingController();
    _minLengthController = TextEditingController();
    _maxLengthController = TextEditingController();
    _inputPatternController = TextEditingController();
    _minValueController = TextEditingController();
    _maxValueController = TextEditingController();
    _decimalPlacesController = TextEditingController();
    _allowedUnitsController = TextEditingController();
    _nameController.addListener(_clearNameError);
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await _store.loadDashboard();
    await _store.loadAttributes();
    _editingAttribute = _store.findAttributeById(widget.args.attributeId);
    if (_editingAttribute != null) {
      _nameController.text = _editingAttribute!.name;
      _codeController.text = _editingAttribute!.code;
      _sortOrderController.text = _editingAttribute!.sortOrder.toString();
      _valueType = _editingAttribute!.valueType;
      _isFilterable = _editingAttribute!.isFilterable;
      _allowedUnitsController.text =
          _editingAttribute!.effectiveUnitLabels.join(', ');
      _minLengthController.text =
          _editingAttribute!.minLength?.toString() ?? '';
      _maxLengthController.text =
          _editingAttribute!.maxLength?.toString() ?? '';
      _inputPatternController.text = _editingAttribute!.inputPattern ?? '';
      _minValueController.text = _editingAttribute!.minValue?.toString() ?? '';
      _maxValueController.text = _editingAttribute!.maxValue?.toString() ?? '';
      _decimalPlacesController.text =
          _editingAttribute!.decimalPlaces?.toString() ?? '';
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_clearNameError);
    _nameController.dispose();
    _codeController.dispose();
    _sortOrderController.dispose();
    _minLengthController.dispose();
    _maxLengthController.dispose();
    _inputPatternController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    _decimalPlacesController.dispose();
    _allowedUnitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editingAttribute == null ? 'New attribute' : 'Edit attribute',
        ),
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
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  border: OutlineInputBorder(),
                  errorMaxLines: 3,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Code is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AttributeValueType>(
                initialValue: _valueType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                  errorMaxLines: 3,
                ),
                items: AttributeValueType.values
                    .map(
                      (valueType) => DropdownMenuItem<AttributeValueType>(
                        value: valueType,
                        child: Text(valueType.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _valueType = value;
                    if (_valueType != AttributeValueType.number) {
                      _allowedUnitsController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isFilterable,
                onChanged: (value) {
                  setState(() {
                    _isFilterable = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
                title: const Text('Filterable'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sortOrderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sort order',
                  border: OutlineInputBorder(),
                  errorMaxLines: 3,
                ),
                validator: _validateIntOrEmpty,
              ),
              ..._buildConstraintFields(),
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
                  _editingAttribute == null
                      ? 'Create attribute'
                      : 'Save changes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConstraintFields() {
    switch (_valueType) {
      case AttributeValueType.dropdown:
      case AttributeValueType.multiselect:
        return const <Widget>[];
      case AttributeValueType.text:
        return <Widget>[
          const SizedBox(height: 16),
          TextFormField(
            controller: _minLengthController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Min length',
              border: OutlineInputBorder(),
              errorMaxLines: 3,
            ),
            validator: _validateIntOrEmpty,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _maxLengthController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Max length',
              border: OutlineInputBorder(),
              errorMaxLines: 3,
            ),
            validator: _validateIntOrEmpty,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _inputPatternController,
            decoration: const InputDecoration(
              labelText: 'Input pattern',
              border: OutlineInputBorder(),
              errorMaxLines: 3,
            ),
          ),
        ];
      case AttributeValueType.number:
        return <Widget>[
          const SizedBox(height: 16),
          TextFormField(
            controller: _allowedUnitsController,
            decoration: const InputDecoration(
              labelText: 'Units',
              helperText: 'Comma-separated, for example: kg, g, lb',
              border: OutlineInputBorder(),
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _minValueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Min value',
              border: OutlineInputBorder(),
              errorMaxLines: 3,
            ),
            validator: _validateNumOrEmpty,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _maxValueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Max value',
              border: OutlineInputBorder(),
              errorMaxLines: 3,
            ),
            validator: _validateNumOrEmpty,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _decimalPlacesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Decimal places',
              border: OutlineInputBorder(),
              errorMaxLines: 3,
            ),
            validator: _validateIntOrEmpty,
          ),
        ];
    }
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
      await _store.saveAttribute(
        Attribute(
          id: _editingAttribute?.id ?? '',
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          valueType: _valueType,
          unitLabel: _valueType == AttributeValueType.number
              ? _parsePrimaryUnit(_allowedUnitsController.text)
              : null,
          allowedUnitLabels: _valueType == AttributeValueType.number
              ? _parseUnits(_allowedUnitsController.text)
              : const <String>[],
          sortOrder: _parseInt(_sortOrderController.text) ?? 0,
          isFilterable: _isFilterable,
          minLength: _valueType == AttributeValueType.text
              ? _parseInt(_minLengthController.text)
              : null,
          maxLength: _valueType == AttributeValueType.text
              ? _parseInt(_maxLengthController.text)
              : null,
          inputPattern: _valueType == AttributeValueType.text
              ? _parseString(_inputPatternController.text)
              : null,
          minValue: _valueType == AttributeValueType.number
              ? _parseNum(_minValueController.text)
              : null,
          maxValue: _valueType == AttributeValueType.number
              ? _parseNum(_maxValueController.text)
              : null,
          decimalPlaces: _valueType == AttributeValueType.number
              ? _parseInt(_decimalPlacesController.text)
              : null,
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
      debugPrint('Failed to save attribute: $error');
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t save attribute. Try again.'),
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

  String? _validateIntOrEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (int.tryParse(value.trim()) == null) {
      return 'Value must be a whole number.';
    }
    return null;
  }

  String? _validateNumOrEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (num.tryParse(value.trim()) == null) {
      return 'Value must be numeric.';
    }
    return null;
  }

  int? _parseInt(String value) =>
      value.trim().isEmpty ? null : int.tryParse(value.trim());

  num? _parseNum(String value) =>
      value.trim().isEmpty ? null : num.tryParse(value.trim());

  String? _parseString(String value) =>
      value.trim().isEmpty ? null : value.trim();

  String? _parsePrimaryUnit(String value) {
    final units = _parseUnits(value);
    return units.isEmpty ? null : units.first;
  }

  List<String> _parseUnits(String value) {
    final units = <String>[];
    final seen = <String>{};
    for (final rawUnit in value.split(',')) {
      final unit = rawUnit.trim();
      if (unit.isEmpty) {
        continue;
      }
      final key = unit.toLowerCase();
      if (seen.add(key)) {
        units.add(unit);
      }
    }
    return units;
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
