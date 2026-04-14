import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_form_decoration.dart';

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
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedParentId;
  bool _isSaving = false;
  bool _isSlugDirty = false;
  String _lastGeneratedSlug = '';
  Category? _editingCategory;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_syncSlugIfPristine);
    _slugController.addListener(_trackSlugOverride);
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await Future.wait([
      _store.loadDashboard(),
      _store.loadCategoryTree(),
    ]);
    final categoryId = widget.args?.categoryId;
    if (categoryId != null) {
      try {
        _editingCategory = await _store.getCategoryById(categoryId);
      } catch (_) {
        _editingCategory = null;
      }
    }

    if (_editingCategory != null) {
      _nameController.text = _editingCategory!.name;
      _slugController.text = _editingCategory!.slug;
      _descriptionController.text = _editingCategory!.description ?? '';
      _selectedParentId = _editingCategory!.parentId;
    } else {
      _selectedParentId = widget.args?.initialParentId;
      _syncGeneratedSlug();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_syncSlugIfPristine);
    _slugController.removeListener(_trackSlugOverride);
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
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
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Name is required.';
                  }
                  if (trimmed.length > 150) {
                    return 'Name must be 150 characters or fewer.';
                  }

                  // Duplicate detection must be enforced by the server.
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slugController,
                decoration: metadataFormDecoration(
                  labelText: 'Slug',
                  helperText: 'Lowercase letters, numbers, and hyphens only.',
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Slug is required.';
                  }
                  if (trimmed.length > 150) {
                    return 'Slug must be 150 characters or fewer.';
                  }
                  if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$')
                      .hasMatch(trimmed)) {
                    return 'Use lowercase letters, numbers, and hyphens only.';
                  }
                  return null;
                },
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
                validator: (value) {
                  if ((value?.trim().length ?? 0) > 1000) {
                    return 'Description must be 1000 characters or fewer.';
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

    return _store.categoryTree.where((category) {
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
    var current = _findCategoryInTree(category.parentId);

    while (current != null) {
      path.insert(0, current.name);
      current = _findCategoryInTree(current.parentId);
    }

    return path.join(' / ');
  }

  Set<String> _descendantIds(String categoryId) {
    final ids = <String>{};

    void collect(String parentId) {
      final children = _store.categoryTree
          .where((cat) => cat.parentId == parentId)
          .toList();
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
      final category = Category(
        id: _editingCategory?.id ?? '',
        tenantId: _editingCategory?.tenantId ?? '',  // TODO: Use actual tenant ID from auth context/current user's session
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        parentId: _selectedParentId,
        description: _trimOrNull(_descriptionController.text),
        createdAt: _editingCategory?.createdAt ?? DateTime.now(),
        updatedAt: _editingCategory?.updatedAt ?? DateTime.now(),
      );
      if (_editingCategory == null) {
        await _store.createCategory(category);
      } else {
        await _store.updateCategory(category);
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _syncSlugIfPristine() {
    if (_isSlugDirty) {
      return;
    }
    _syncGeneratedSlug();
  }

  void _syncGeneratedSlug() {
    _lastGeneratedSlug = _generateSlug(_nameController.text);
    _slugController.value = TextEditingValue(
      text: _lastGeneratedSlug,
      selection: TextSelection.collapsed(offset: _lastGeneratedSlug.length),
    );
  }

  void _trackSlugOverride() {
    _isSlugDirty = _slugController.text.trim() != _lastGeneratedSlug;
  }

  String _generateSlug(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return normalized;
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Category? _findCategoryInTree(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return null;
    }
    for (final category in _store.categoryTree) {
      if (category.id == categoryId) {
        return category;
      }
    }
    return null;
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
