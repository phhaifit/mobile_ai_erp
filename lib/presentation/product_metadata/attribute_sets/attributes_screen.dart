import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_form_decoration.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

enum _AttributeSortOption {
  sortOrder('Sort order'),
  nameAsc('Name A-Z'),
  nameDesc('Name Z-A'),
  valueType('Value type');

  const _AttributeSortOption(this.label);

  final String label;
}

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
    extends State<ProductMetadataAttributesScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      await _store.loadDashboard();
      await _store.loadAttributes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attributes'),
        actions: <Widget>[
          IconButton(
            onPressed: _goToProductMetadataHome,
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Back to Product Metadata',
          ),
        ],
      ),
      floatingActionButton: Observer(
        builder: (context) => FloatingActionButton.extended(
          onPressed: () => ProductMetadataNavigator.openAttributeForm(context),
          icon: const Icon(Icons.add),
          label: const Text('Add attribute'),
        ),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && !_store.hasLoadedDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          return _AttributesListTab(store: _store);
        },
      ),
    );
  }

  void _goToProductMetadataHome() {
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name ==
              ProductMetadataNavigator.productMetadataHomeRoute ||
          route.isFirst,
    );
  }
}

class _AttributesListTab extends StatefulWidget {
  const _AttributesListTab({required this.store});

  final ProductMetadataStore store;

  @override
  State<_AttributesListTab> createState() => _AttributesListTabState();
}

class _AttributesListTabState extends State<_AttributesListTab> {
  static const int _pageSize = 10;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  AttributeValueType? _valueTypeFilter;
  bool _filterableOnly = false;
  _AttributeSortOption _sortOption = _AttributeSortOption.sortOrder;
  int _currentPage = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        if (widget.store.attributes.isEmpty) {
          return const MetadataEmptyState(
            icon: Icons.tune_outlined,
            title: 'No attributes yet',
            message:
                'Add the first attribute to define reusable product metadata.',
          );
        }

        final filteredAttributes =
            _applyFilters(widget.store.attributes.toList());
        final totalPages = _totalPages(filteredAttributes.length);
        final currentPage =
            totalPages == 0 ? 1 : _currentPage.clamp(1, totalPages);
        final visibleAttributes =
            _pageItems(filteredAttributes, currentPage, _pageSize);

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: MetadataListControls(
                searchController: _searchController,
                onSearchChanged: (value) => setState(() {
                  _query = value.trim();
                  _currentPage = 1;
                }),
                searchHint: 'Search by name, code, type, or unit',
                resultLabel:
                    'Showing ${visibleAttributes.length} of ${filteredAttributes.length} attributes',
                hasActiveFilter: _valueTypeFilter != null || _filterableOnly,
                hasCustomSort: _sortOption != _AttributeSortOption.sortOrder,
                onOpenFilter: _openFilterSheet,
                onOpenSort: _openSortSheet,
              ),
            ),
            Expanded(
              child: filteredAttributes.isEmpty
                  ? const MetadataEmptyState(
                      icon: Icons.tune_outlined,
                      title: 'No matching attributes',
                      message:
                          'Try changing your search, filter, or sort order.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemBuilder: (context, index) {
                        if (index >= visibleAttributes.length) {
                          return MetadataPaginationControls(
                            currentPage: currentPage,
                            totalPages: totalPages,
                            onPrevious: currentPage > 1
                                ? () => setState(() {
                                      _currentPage = currentPage - 1;
                                    })
                                : null,
                            onNext: currentPage < totalPages
                                ? () => setState(() {
                                      _currentPage = currentPage + 1;
                                    })
                                : null,
                          );
                        }

                        final attribute = visibleAttributes[index];
                        return MetadataListCard(
                          title: attribute.name,
                          leading: const Icon(Icons.label_outline),
                          detailLines: _attributeSummary(
                            attribute,
                            widget.store.optionCountForAttribute(attribute.id),
                          ),
                          chips: <Widget>[
                            MetadataStatusChip(
                                label: attribute.valueType.label),
                            if (attribute.isFilterable)
                              const MetadataStatusChip(label: 'Filterable'),
                          ],
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'options':
                                  ProductMetadataNavigator.openAttributeOptions(
                                    context,
                                    args: AttributeOptionsArgs(
                                        attributeId: attribute.id),
                                  );
                                  break;
                                case 'edit':
                                  ProductMetadataNavigator.openAttributeForm(
                                    context,
                                    args: AttributeFormArgs(
                                        attributeId: attribute.id),
                                  );
                                  break;
                                case 'delete':
                                  _deleteAttribute(
                                      context, widget.store, attribute);
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
                          onTap: () =>
                              ProductMetadataNavigator.openAttributeDetail(
                            context,
                            args:
                                AttributeDetailArgs(attributeId: attribute.id),
                          ),
                        );
                      },
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemCount:
                          visibleAttributes.length + (totalPages > 1 ? 1 : 0),
                    ),
            ),
          ],
        );
      },
    );
  }

  List<Attribute> _applyFilters(List<Attribute> attributes) {
    final query = _query.toLowerCase();
    final filtered = attributes.where((attribute) {
      if (_valueTypeFilter != null && attribute.valueType != _valueTypeFilter) {
        return false;
      }
      if (_filterableOnly && !attribute.isFilterable) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final units = attribute.effectiveUnitLabels.join(' ').toLowerCase();
      return attribute.name.toLowerCase().contains(query) ||
          attribute.code.toLowerCase().contains(query) ||
          attribute.valueType.label.toLowerCase().contains(query) ||
          units.contains(query);
    }).toList();

    filtered.sort((left, right) {
      switch (_sortOption) {
        case _AttributeSortOption.sortOrder:
          final orderCompare = left.sortOrder.compareTo(right.sortOrder);
          if (orderCompare != 0) {
            return orderCompare;
          }
          return left.name.toLowerCase().compareTo(right.name.toLowerCase());
        case _AttributeSortOption.nameAsc:
          return left.name.toLowerCase().compareTo(right.name.toLowerCase());
        case _AttributeSortOption.nameDesc:
          return right.name.toLowerCase().compareTo(left.name.toLowerCase());
        case _AttributeSortOption.valueType:
          final typeCompare =
              left.valueType.label.compareTo(right.valueType.label);
          if (typeCompare != 0) {
            return typeCompare;
          }
          return left.name.toLowerCase().compareTo(right.name.toLowerCase());
      }
    });

    return filtered;
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_AttributeFilterState>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        AttributeValueType? tempValueType = _valueTypeFilter;
        bool tempFilterableOnly = _filterableOnly;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Filter attributes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('All types'),
                                trailing: tempValueType == null
                                    ? const Icon(Icons.check)
                                    : null,
                                onTap: () => setModalState(() {
                                  tempValueType = null;
                                }),
                              ),
                              for (final valueType in AttributeValueType.values)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(valueType.label),
                                  trailing: tempValueType == valueType
                                      ? const Icon(Icons.check)
                                      : null,
                                  onTap: () => setModalState(() {
                                    tempValueType = valueType;
                                  }),
                                ),
                              SwitchListTile(
                                value: tempFilterableOnly,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (value) => setModalState(() {
                                  tempFilterableOnly = value;
                                }),
                                title: const Text('Filterable only'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(
                          _AttributeFilterState(
                            valueType: tempValueType,
                            filterableOnly: tempFilterableOnly,
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _valueTypeFilter = result.valueType;
      _filterableOnly = result.filterableOnly;
      _currentPage = 1;
    });
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<_AttributeSortOption>(
      context: context,
      builder: (context) {
        _AttributeSortOption tempSort = _sortOption;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Sort attributes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    for (final option in _AttributeSortOption.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(option.label),
                        trailing:
                            tempSort == option ? const Icon(Icons.check) : null,
                        onTap: () => setModalState(() {
                          tempSort = option;
                        }),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(tempSort),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _sortOption = selected;
      _currentPage = 1;
    });
  }

  int _totalPages(int itemCount) =>
      itemCount == 0 ? 0 : ((itemCount - 1) ~/ _pageSize) + 1;

  List<Attribute> _pageItems(List<Attribute> items, int page, int pageSize) {
    final start = (page - 1) * pageSize;
    if (start >= items.length) {
      return const <Attribute>[];
    }
    final end = (start + pageSize).clamp(0, items.length);
    return items.sublist(start, end);
  }

  List<String> _attributeSummary(Attribute attribute, int optionCount) {
    return <String>[
      'Code: ${attribute.code}',
      'Sort order: ${attribute.sortOrder}',
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

class _AttributeFilterState {
  const _AttributeFilterState({
    required this.valueType,
    required this.filterableOnly,
  });

  final AttributeValueType? valueType;
  final bool filterableOnly;
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
  late final TextEditingController _descriptionController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _minLengthController;
  late final TextEditingController _maxLengthController;
  late final TextEditingController _inputPatternController;
  late final TextEditingController _minValueController;
  late final TextEditingController _maxValueController;
  late final TextEditingController _decimalPlacesController;
  late final TextEditingController _unitInputController;
  AttributeValueType _valueType = AttributeValueType.dropdown;
  bool _isFilterable = true;
  bool _isSaving = false;
  String? _nameErrorText;
  Attribute? _editingAttribute;
  final List<String> _units = <String>[];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _descriptionController = TextEditingController();
    _sortOrderController = TextEditingController();
    _minLengthController = TextEditingController();
    _maxLengthController = TextEditingController();
    _inputPatternController = TextEditingController();
    _minValueController = TextEditingController();
    _maxValueController = TextEditingController();
    _decimalPlacesController = TextEditingController();
    _unitInputController = TextEditingController();
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
      _descriptionController.text = _editingAttribute!.description ?? '';
      _sortOrderController.text = _editingAttribute!.sortOrder.toString();
      _valueType = _editingAttribute!.valueType;
      _isFilterable = _editingAttribute!.isFilterable;
      _units
        ..clear()
        ..addAll(_editingAttribute!.effectiveUnitLabels);
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
    _descriptionController.dispose();
    _sortOrderController.dispose();
    _minLengthController.dispose();
    _maxLengthController.dispose();
    _inputPatternController.dispose();
    _minValueController.dispose();
    _maxValueController.dispose();
    _decimalPlacesController.dispose();
    _unitInputController.dispose();
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
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  errorMaxLines: 3,
                ),
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
                      _unitInputController.clear();
                      _units.clear();
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
          _UnitChipInput(
            units: _units,
            controller: _unitInputController,
            onSubmitted: _addUnitsFromInput,
            onRemove: _removeUnit,
            helperText:
                'Add one unit at a time. Press Enter or comma, for example: kg, g, lb',
            onChanged: (_) {
              if (_unitInputController.text.contains(',')) {
                _addUnitsFromInput(_unitInputController.text);
              }
            },
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
          description: _parseString(_descriptionController.text),
          valueType: _valueType,
          unitLabel: _valueType == AttributeValueType.number
              ? _parsePrimaryUnit(_serializedUnits)
              : null,
          allowedUnitLabels: _valueType == AttributeValueType.number
              ? _parseUnits(_serializedUnits)
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

  String get _serializedUnits {
    final combined = <String>[
      ..._units,
      if (_unitInputController.text.trim().isNotEmpty)
        _unitInputController.text,
    ];
    return combined.join(', ');
  }

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

  void _addUnitsFromInput(String rawValue) {
    final parsed = _parseUnits(rawValue);
    if (parsed.isEmpty) {
      return;
    }

    setState(() {
      final seen = _units.map((unit) => unit.toLowerCase()).toSet();
      for (final unit in parsed) {
        if (seen.add(unit.toLowerCase())) {
          _units.add(unit);
        }
      }
      _unitInputController.clear();
    });
  }

  void _removeUnit(String unit) {
    setState(() {
      _units.remove(unit);
    });
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

class _UnitChipInput extends StatelessWidget {
  const _UnitChipInput({
    required this.units,
    required this.controller,
    required this.onSubmitted,
    required this.onRemove,
    required this.helperText,
    required this.onChanged,
  });

  final List<String> units;
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onRemove;
  final String helperText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (units.isNotEmpty) ...<Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: units
                .map(
                  (unit) => InputChip(
                    label: Text(unit),
                    onDeleted: () => onRemove(unit),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: metadataFormDecoration(
            labelText: 'Units',
            helperText: helperText,
            hintText: 'Type a unit and press Enter',
          ).copyWith(
            suffixIcon: IconButton(
              onPressed: () => onSubmitted(controller.text),
              icon: const Icon(Icons.add),
              tooltip: 'Add unit',
            ),
          ),
        ),
        if (units.isEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            'No units added yet.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}
