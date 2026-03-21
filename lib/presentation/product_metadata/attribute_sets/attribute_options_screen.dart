import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute_option.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

enum _AttributeOptionSortOption {
  sortOrder('Sort order'),
  valueAsc('Value A-Z'),
  valueDesc('Value Z-A');

  const _AttributeOptionSortOption(this.label);

  final String label;
}

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
  static const int _pageSize = 5;

  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int? _sortOrderFilter;
  _AttributeOptionSortOption _sortOption = _AttributeOptionSortOption.sortOrder;
  int _currentPage = 1;

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (context) {
            final attribute = _store.findAttributeById(widget.args.attributeId);
            return Text(
              attribute == null
                  ? 'Attribute Options'
                  : '${attribute.name} Options',
            );
          },
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
              _store.activeAttributeId == widget.args.attributeId) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_store.attributeOptions.isEmpty) {
            return const MetadataEmptyState(
              icon: Icons.list_alt_outlined,
              title: 'No options yet',
              message:
                  'Add the first option to define selectable values for this attribute.',
            );
          }

          final filteredOptions =
              _applyFilters(_store.attributeOptions.toList());
          final totalPages = _totalPages(filteredOptions.length);
          final currentPage =
              totalPages == 0 ? 1 : _currentPage.clamp(1, totalPages);
          final visibleOptions =
              _pageItems(filteredOptions, currentPage, _pageSize);

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
                  searchHint: 'Search by option value or sort order',
                  resultLabel:
                      'Showing ${visibleOptions.length} of ${filteredOptions.length} options',
                  hasActiveFilter: _sortOrderFilter != null,
                  hasCustomSort:
                      _sortOption != _AttributeOptionSortOption.sortOrder,
                  onOpenFilter: _openFilterSheet,
                  onOpenSort: _openSortSheet,
                ),
              ),
              Expanded(
                child: filteredOptions.isEmpty
                    ? const MetadataEmptyState(
                        icon: Icons.list_alt_outlined,
                        title: 'No matching options',
                        message:
                            'Try changing your search, filter, or sort order.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount:
                            visibleOptions.length + (totalPages > 1 ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index >= visibleOptions.length) {
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

                          final option = visibleOptions[index];
                          return MetadataListCard(
                            title: option.value,
                            leading:
                                const Icon(Icons.radio_button_checked_outlined),
                            detailLines: _optionSummary(option),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    ProductMetadataNavigator
                                        .openAttributeOptionForm(
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
                              itemBuilder: (context) =>
                                  const <PopupMenuEntry<String>>[
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<AttributeOption> _applyFilters(List<AttributeOption> options) {
    final query = _query.toLowerCase();
    final filtered = options.where((option) {
      if (_sortOrderFilter != null && option.sortOrder != _sortOrderFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return option.value.toLowerCase().contains(query) ||
          option.sortOrder.toString().contains(query);
    }).toList();

    filtered.sort((left, right) {
      switch (_sortOption) {
        case _AttributeOptionSortOption.sortOrder:
          final orderCompare = left.sortOrder.compareTo(right.sortOrder);
          if (orderCompare != 0) {
            return orderCompare;
          }
          return left.value.toLowerCase().compareTo(right.value.toLowerCase());
        case _AttributeOptionSortOption.valueAsc:
          return left.value.toLowerCase().compareTo(right.value.toLowerCase());
        case _AttributeOptionSortOption.valueDesc:
          return right.value.toLowerCase().compareTo(left.value.toLowerCase());
      }
    });

    return filtered;
  }

  Future<void> _openFilterSheet() async {
    final availableSortOrders = _store.attributeOptions
        .map((option) => option.sortOrder)
        .toSet()
        .toList()
      ..sort();

    final result = await showModalBottomSheet<_AttributeOptionFilterResult>(
      context: context,
      builder: (context) {
        int? tempSortOrder = _sortOrderFilter;
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
                      'Filter options',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('All sort orders'),
                      trailing: tempSortOrder == null
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () => setModalState(() {
                        tempSortOrder = null;
                      }),
                    ),
                    for (final sortOrder in availableSortOrders)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Sort order: $sortOrder'),
                        trailing: tempSortOrder == sortOrder
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => setModalState(() {
                          tempSortOrder = sortOrder;
                        }),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(
                        _AttributeOptionFilterResult(
                          sortOrder: tempSortOrder,
                        ),
                      ),
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

    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _sortOrderFilter = result.sortOrder;
      _currentPage = 1;
    });
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<_AttributeOptionSortOption>(
      context: context,
      builder: (context) {
        _AttributeOptionSortOption tempSort = _sortOption;
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
                      'Sort options',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    for (final option in _AttributeOptionSortOption.values)
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

  List<AttributeOption> _pageItems(
    List<AttributeOption> items,
    int page,
    int pageSize,
  ) {
    final start = (page - 1) * pageSize;
    if (start >= items.length) {
      return const <AttributeOption>[];
    }
    final end = (start + pageSize).clamp(0, items.length);
    return items.sublist(start, end);
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

class _AttributeOptionFilterResult {
  const _AttributeOptionFilterResult({required this.sortOrder});

  final int? sortOrder;
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
