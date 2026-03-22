import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_form_decoration.dart';
import 'package:mobile_ai_erp/core/utils/slug_util.dart';
import 'package:flutter/material.dart';

class ProductMetadataCategoryFormScreen extends StatefulWidget {
  const ProductMetadataCategoryFormScreen({
    super.key,
    this.args,
  });

  final CategoryFormArgs? args;

  @override
  State<ProductMetadataCategoryFormScreen> createState() =>
      _ProductMetadataCategoryFormScreenState();
}

class _ProductMetadataCategoryFormScreenState
    extends State<ProductMetadataCategoryFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _coverImageUrlController =
      TextEditingController();
  final TextEditingController _sortOrderController = TextEditingController();

  String? _selectedParentId;
  CategoryStatus _status = CategoryStatus.active;
  bool _isSaving = false;
  Category? _editingCategory;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_syncSlug);
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await _store.loadDashboard();
    _editingCategory = _store.findCategoryById(widget.args?.categoryId);

    if (_editingCategory != null) {
      _nameController.text = _editingCategory!.name;
      _codeController.text = _editingCategory!.code;
      _slugController.text = _editingCategory!.slug;
      _descriptionController.text = _editingCategory!.description ?? '';
      _coverImageUrlController.text = _editingCategory!.coverImageUrl ?? '';
      _sortOrderController.text = _editingCategory!.sortOrder.toString();
      _selectedParentId = _editingCategory!.parentId;
      _status = _editingCategory!.status;
    } else {
      _selectedParentId = widget.args?.initialParentId;
      _sortOrderController.text = '0';
    }

    _syncSlug();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_syncSlug);
    _nameController.dispose();
    _codeController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _coverImageUrlController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableParents = _availableParents();

    return Scaffold(
      appBar: AppBar(
        title:
            Text(_editingCategory == null ? 'New category' : 'Edit category'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: metadataFormDecoration(
                  labelText: 'Name',
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
                decoration: metadataFormDecoration(
                  labelText: 'Code',
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
                controller: _slugController,
                enabled: false,
                decoration: metadataFormDecoration(
                  labelText: 'Slug',
                  helperText:
                      'Slug is generated automatically from the category path.',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                isExpanded: true,
                initialValue: _selectedParentId,
                decoration: metadataFormDecoration(
                  labelText: 'Parent',
                ),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: _DropdownLabel('No parent (top-level category)'),
                  ),
                  ...availableParents.map(
                    (category) => DropdownMenuItem<String?>(
                      value: category.id,
                      child: _DropdownLabel(_parentOptionLabel(category)),
                    ),
                  ),
                ],
                selectedItemBuilder: (context) => <Widget>[
                  const _DropdownLabel('No parent (top-level category)'),
                  ...availableParents.map(
                    (category) => _DropdownLabel(_parentOptionLabel(category)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedParentId = value;
                    _syncSlug();
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CategoryStatus>(
                initialValue: _status,
                decoration: metadataFormDecoration(
                  labelText: 'Status',
                ),
                items: CategoryStatus.values
                    .map(
                      (status) => DropdownMenuItem<CategoryStatus>(
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
                controller: _descriptionController,
                decoration: metadataFormDecoration(
                  labelText: 'Description',
                ),
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _coverImageUrlController,
                decoration: metadataFormDecoration(
                  labelText: 'Cover image URL',
                ),
              ),
              const SizedBox(height: 16),
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
                label: Text(_editingCategory == null
                    ? 'Create category'
                    : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Category> _availableParents() {
    final editingCategoryId = _editingCategory?.id;
    final descendantIds = editingCategoryId == null
        ? <String>{}
        : _descendantIds(editingCategoryId);

    return _store.categories.where((category) {
      if (category.id == editingCategoryId) {
        return false;
      }
      if (descendantIds.contains(category.id)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((left, right) => _parentOptionLabel(left)
          .toLowerCase()
          .compareTo(_parentOptionLabel(right).toLowerCase()));
  }

  String _parentOptionLabel(Category category) {
    final path = <String>[category.name];
    var current = _store.findCategoryById(category.parentId);

    while (current != null) {
      path.insert(0, current.name);
      current = _store.findCategoryById(current.parentId);
    }

    return path.join(' / ');
  }

  Set<String> _descendantIds(String categoryId) {
    final ids = <String>{};

    void collect(String parentId) {
      final children = _store.childrenOf(parentId);
      for (final child in children) {
        if (ids.add(child.id)) {
          collect(child.id);
        }
      }
    }

    collect(categoryId);
    return ids;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _store.saveCategory(
        Category(
          id: _editingCategory?.id ?? '',
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          slug: _slugController.text.trim(),
          parentId: _selectedParentId,
          sortOrder: int.parse(_sortOrderController.text.trim()),
          status: _status,
          description: _trimOrNull(_descriptionController.text),
          coverImageUrl: _trimOrNull(_coverImageUrlController.text),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t save category. Try again.'),
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

  void _syncSlug() {
    _slugController.text = _buildSlugPreview();
  }

  String _buildSlugPreview() {
    final ownSlug = SlugUtil.slugify(_nameController.text);
    if (_selectedParentId == null) {
      return ownSlug;
    }

    final parentSegments = <String>[];
    final visitedIds = <String>{
      if (_editingCategory != null) _editingCategory!.id,
    };
    String? cursor = _selectedParentId;

    while (cursor != null) {
      final parent = _store.findCategoryById(cursor);
      if (parent == null || !visitedIds.add(parent.id)) {
        break;
      }
      parentSegments.insert(0, SlugUtil.slugify(parent.name));
      cursor = parent.parentId;
    }

    return <String>[...parentSegments, ownSlug].join('/');
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _DropdownLabel extends StatelessWidget {
  const _DropdownLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
    );
  }
}
