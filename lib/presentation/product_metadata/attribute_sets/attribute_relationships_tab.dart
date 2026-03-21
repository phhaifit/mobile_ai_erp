import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category_attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_form_decoration.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class AttributeRelationshipsTab extends StatefulWidget {
  const AttributeRelationshipsTab({super.key, required this.store});

  final ProductMetadataStore store;

  @override
  State<AttributeRelationshipsTab> createState() =>
      _AttributeRelationshipsTabState();
}

class _AttributeRelationshipsTabState extends State<AttributeRelationshipsTab> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final categories = widget.store.categories.toList()
          ..sort((a, b) {
            final orderCompare = a.sortOrder.compareTo(b.sortOrder);
            if (orderCompare != 0) {
              return orderCompare;
            }
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

        if (categories.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Create at least one category before managing attribute relationships.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        _selectedCategoryId ??= categories.first.id;
        if (!categories.any((category) => category.id == _selectedCategoryId)) {
          _selectedCategoryId = categories.first.id;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return Row(
                children: <Widget>[
                  SizedBox(
                    width: 280,
                    child: _RelationshipsCategoryRail(
                      categories: categories,
                      selectedCategoryId: _selectedCategoryId,
                      onSelected: _onCategorySelected,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: _RelationshipsContent(
                      store: widget.store,
                      selectedCategoryId: _selectedCategoryId!,
                      onAdd: () => _openRelationshipForm(context),
                      onEdit: (relationship) => _openRelationshipForm(
                        context,
                        relationship: relationship,
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories
                        .map(
                          (category) => DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(
                              _buildCategoryPathLabel(
                                category,
                                categories,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _onCategorySelected(value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _RelationshipsContent(
                    store: widget.store,
                    selectedCategoryId: _selectedCategoryId!,
                    onAdd: () => _openRelationshipForm(context),
                    onEdit: (relationship) => _openRelationshipForm(
                      context,
                      relationship: relationship,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onCategorySelected(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  Future<void> _openRelationshipForm(
    BuildContext context, {
    CategoryAttribute? relationship,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ProductMetadataCategoryRelationshipFormScreen(
          relationship: relationship,
          initialCategoryId: relationship?.categoryId ?? _selectedCategoryId,
        ),
      ),
    );
  }
}

String _buildCategoryPathLabel(
  Category category,
  Iterable<Category> allCategories,
) {
  final categoriesById = <String, Category>{
    for (final item in allCategories) item.id: item,
  };
  final segments = <String>[category.name];
  final visitedIds = <String>{category.id};
  var currentParentId = category.parentId;

  while (currentParentId != null) {
    final parent = categoriesById[currentParentId];
    if (parent == null || !visitedIds.add(parent.id)) {
      break;
    }
    segments.insert(0, parent.name);
    currentParentId = parent.parentId;
  }

  return segments.join(' / ');
}

class _RelationshipsCategoryRail extends StatelessWidget {
  const _RelationshipsCategoryRail({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category.id == selectedCategoryId;
        return Material(
          color: isSelected
              ? Theme.of(context).colorScheme.secondaryContainer
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onSelected(category.id),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _buildCategoryPathLabel(category, categories),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.code,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: categories.length,
    );
  }
}

class _RelationshipsContent extends StatefulWidget {
  const _RelationshipsContent({
    required this.store,
    required this.selectedCategoryId,
    required this.onAdd,
    required this.onEdit,
  });

  final ProductMetadataStore store;
  final String selectedCategoryId;
  final VoidCallback onAdd;
  final ValueChanged<CategoryAttribute> onEdit;

  @override
  State<_RelationshipsContent> createState() => _RelationshipsContentState();
}

class _RelationshipsContentState extends State<_RelationshipsContent> {
  static const int _pageSize = 2;

  int _currentPage = 1;

  @override
  void didUpdateWidget(covariant _RelationshipsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategoryId != widget.selectedCategoryId) {
      _currentPage = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final category =
            widget.store.findCategoryById(widget.selectedCategoryId);
        final relationships = widget.store
            .categoryAttributesForCategory(widget.selectedCategoryId);
        final totalPages = _totalPages(relationships.length);
        final currentPage =
            totalPages == 0 ? 1 : _currentPage.clamp(1, totalPages);
        final visibleRelationships =
            _pageItems(relationships, currentPage, _pageSize);

        if (category == null) {
          return const Center(child: Text('Category not found.'));
        }

        return Column(
          children: <Widget>[
            Expanded(
              child: relationships.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No attribute relationships yet for this category.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemBuilder: (context, index) {
                        if (index >= visibleRelationships.length) {
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

                        final relationship = visibleRelationships[index];
                        final attribute = widget.store
                            .findAttributeById(relationship.attributeId);
                        return MetadataListCard(
                          title: attribute?.name ?? relationship.attributeId,
                          leading: const Icon(Icons.link_outlined),
                          detailLines: <String>[
                            if (attribute != null) 'Code: ${attribute.code}',
                            'Sort order: ${relationship.sortOrder}',
                          ],
                          chips: <Widget>[
                            if (attribute != null)
                              MetadataStatusChip(
                                label: attribute.valueType.label,
                              ),
                            MetadataStatusChip(
                              label: relationship.isRequired
                                  ? 'Required'
                                  : 'Optional',
                            ),
                          ],
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  widget.onEdit(relationship);
                                  break;
                                case 'remove':
                                  _deleteRelationship(
                                    context,
                                    widget.store,
                                    relationship,
                                  );
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
                                value: 'remove',
                                child: Text('Remove'),
                              ),
                            ],
                          ),
                          onTap: () => widget.onEdit(relationship),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: visibleRelationships.length +
                          (totalPages > 1 ? 1 : 0),
                    ),
            ),
          ],
        );
      },
    );
  }

  int _totalPages(int itemCount) =>
      itemCount == 0 ? 0 : ((itemCount - 1) ~/ _pageSize) + 1;

  List<CategoryAttribute> _pageItems(
    List<CategoryAttribute> items,
    int page,
    int pageSize,
  ) {
    final start = (page - 1) * pageSize;
    if (start >= items.length) {
      return const <CategoryAttribute>[];
    }
    final end = (start + pageSize).clamp(0, items.length);
    return items.sublist(start, end);
  }

  Future<void> _deleteRelationship(
    BuildContext context,
    ProductMetadataStore store,
    CategoryAttribute relationship,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Remove relationship?'),
              content: const Text(
                'This will remove the selected attribute from the category.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Remove'),
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
      await store.deleteCategoryAttribute(relationship.id);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Relationship removed.')),
      );
    } catch (error) {
      debugPrint('Failed to delete relationship: $error');
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t remove relationship. Try again.'),
        ),
      );
    }
  }
}

class ProductMetadataCategoryRelationshipFormScreen extends StatefulWidget {
  const ProductMetadataCategoryRelationshipFormScreen({
    super.key,
    this.relationship,
    this.initialCategoryId,
  });

  final CategoryAttribute? relationship;
  final String? initialCategoryId;

  @override
  State<ProductMetadataCategoryRelationshipFormScreen> createState() =>
      _ProductMetadataCategoryRelationshipFormScreenState();
}

class _ProductMetadataCategoryRelationshipFormScreenState
    extends State<ProductMetadataCategoryRelationshipFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _sortOrderController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedAttributeId;
  bool _isRequired = false;
  bool _isSaving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await _store.loadDashboard();
    await _store.loadAttributes();
    final categoryOptions = _uniqueCategories();
    final editing = widget.relationship;
    _selectedCategoryId = editing?.categoryId ?? widget.initialCategoryId;
    _selectedAttributeId = editing?.attributeId;
    _isRequired = editing?.isRequired ?? false;
    _sortOrderController.text = (editing?.sortOrder ?? 0).toString();
    _selectedCategoryId ??=
        categoryOptions.isEmpty ? null : categoryOptions.first.id;
    _selectedAttributeId = _syncSelectedAttribute(
      currentAttributeId: _selectedAttributeId,
      availableAttributes: _availableAttributes(),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableAttributes = _availableAttributes();
    final categoryOptions = _uniqueCategories();
    final selectedCategoryValue = _resolveDropdownValue(
      currentValue: _selectedCategoryId,
      optionValues: categoryOptions.map((category) => category.id),
    );
    final selectedAttributeValue = _resolveDropdownValue(
      currentValue: _selectedAttributeId,
      optionValues: availableAttributes.map((attribute) => attribute.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.relationship == null
              ? 'New relationship'
              : 'Edit relationship',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedCategoryValue,
                decoration: metadataFormDecoration(
                  labelText: 'Category',
                  errorText: _errorText,
                ),
                items: categoryOptions
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(
                          _buildCategoryPathLabel(category, categoryOptions),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                    _selectedAttributeId = _syncSelectedAttribute(
                      currentAttributeId: _selectedAttributeId,
                      availableAttributes: _availableAttributes(value),
                    );
                    _errorText = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedAttributeValue,
                decoration: metadataFormDecoration(
                  labelText: 'Attribute',
                ),
                items: availableAttributes
                    .map(
                      (attribute) => DropdownMenuItem<String>(
                        value: attribute.id,
                        child: Text(
                          '${attribute.name} (${attribute.code})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAttributeId = value;
                    _errorText = null;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Attribute is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isRequired,
                onChanged: (value) => setState(() => _isRequired = value),
                contentPadding: EdgeInsets.zero,
                title: const Text('Required'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _sortOrderController,
                keyboardType: TextInputType.number,
                decoration: metadataFormDecoration(
                  labelText: 'Sort order',
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
                  widget.relationship == null
                      ? 'Create relationship'
                      : 'Save changes',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Attribute> _availableAttributes([String? categoryId]) {
    final effectiveCategoryId = categoryId ?? _selectedCategoryId;
    if (effectiveCategoryId == null) {
      return _uniqueAttributes(_store.attributes);
    }
    final linkedIds = _store.categoryAttributes
        .where((item) => item.categoryId == effectiveCategoryId)
        .map((item) => item.attributeId)
        .toSet();
    final editingAttributeId = widget.relationship?.attributeId;

    final available = _store.attributes.where((attribute) {
      if (attribute.id == editingAttributeId) {
        return true;
      }
      return !linkedIds.contains(attribute.id);
    }).toList();

    return _uniqueAttributes(available)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<Category> _uniqueCategories() {
    final uniqueById = <String, Category>{};
    for (final category in _store.categories) {
      uniqueById[category.id] = category;
    }
    final categories = uniqueById.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return categories;
  }

  List<Attribute> _uniqueAttributes(Iterable<Attribute> source) {
    final uniqueById = <String, Attribute>{};
    for (final attribute in source) {
      uniqueById[attribute.id] = attribute;
    }
    return uniqueById.values.toList();
  }

  String? _syncSelectedAttribute({
    required String? currentAttributeId,
    required List<Attribute> availableAttributes,
  }) {
    if (currentAttributeId != null &&
        availableAttributes.any((item) => item.id == currentAttributeId)) {
      return currentAttributeId;
    }
    return availableAttributes.isEmpty ? null : availableAttributes.first.id;
  }

  String? _resolveDropdownValue({
    required String? currentValue,
    required Iterable<String> optionValues,
  }) {
    if (currentValue == null) {
      return null;
    }
    final matches = optionValues.where((value) => value == currentValue).length;
    return matches == 1 ? currentValue : null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _errorText = 'Category is required.');
      return;
    }
    if (_selectedAttributeId == null) {
      setState(() => _errorText = 'Attribute is required.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      await _store.saveCategoryAttribute(
        CategoryAttribute(
          id: widget.relationship?.id ?? '',
          categoryId: _selectedCategoryId!,
          attributeId: _selectedAttributeId!,
          isRequired: _isRequired,
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
        _errorText = error.message;
      });
    } catch (error) {
      debugPrint('Failed to save relationship: $error');
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t save relationship. Try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
