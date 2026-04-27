import 'package:flutter/material.dart';
import 'package:validators/validators.dart' as v;
import 'package:mobile_ai_erp/core/utils/slug_util.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_form_body.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';

class ProductMetadataCategoryFormScreen extends StatefulWidget {
  const ProductMetadataCategoryFormScreen({super.key, this.args});
  final CategoryFormArgs? args;
  @override
  State<ProductMetadataCategoryFormScreen> createState() => _ProductMetadataCategoryFormScreenState();
}
class _ProductMetadataCategoryFormScreenState extends State<ProductMetadataCategoryFormScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedParentId;
  CategoryStatus _status = CategoryStatus.active;
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
    await Future.wait([_store.loadDashboard(), _store.loadCategoryTree()]);
    final categoryId = widget.args?.categoryId;
    if (categoryId != null) {
      try { _editingCategory = await _store.getCategoryById(categoryId); } catch (_) {}
    }
    if (_editingCategory != null) {
      _nameController.text = _editingCategory!.name;
      _slugController.text = _editingCategory!.slug;
      _descriptionController.text = _editingCategory!.description ?? '';
      _selectedParentId = _editingCategory!.parentId;
      _status = _editingCategory!.status;
    } else {
      _selectedParentId = widget.args?.initialParentId;
      _syncGeneratedSlug();
    }
    if (mounted) setState(() {});
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
    final editingId = _editingCategory?.id;
    final parentOptions = _store.categoryTree.where((c) => c.id != editingId).toList()..sort((a, b) => _label(a).toLowerCase().compareTo(_label(b).toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: Text(_editingCategory == null ? 'New category' : 'Edit category')),
      body: CategoryFormBody(formKey: _formKey, nameController: _nameController, slugController: _slugController, descriptionController: _descriptionController, parentOptions: parentOptions, selectedParentId: _selectedParentId, status: _status, isSaving: _isSaving, isEditing: _editingCategory != null, onParentChanged: (val) => setState(() => _selectedParentId = val), onStatusChanged: (val) => setState(() => _status = val), onSave: _save, validateSlug: _validateSlugFormat),
    );
  }
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final category = Category(id: _editingCategory?.id ?? '', tenantId: _editingCategory?.tenantId ?? '', name: _nameController.text.trim(), slug: _slugController.text.trim(), parentId: _selectedParentId, description: _trimOrNull(_descriptionController.text), status: _status, createdAt: _editingCategory?.createdAt ?? DateTime.now(), updatedAt: _editingCategory?.updatedAt ?? DateTime.now());
      if (_editingCategory == null) { await _store.createCategory(category); } else { await _store.updateCategory(category); }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(MetadataErrorFormatter.formatActionError(error: error, actionLabel: _editingCategory == null ? 'create category' : 'save category'))));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  String _label(Category c) {
    final path = <String>[c.name];
    String? parentId = c.parentId;
    while (parentId != null) {
      final parent = _store.categoryTree.where((x) => x.id == parentId).firstOrNull;
      if (parent == null) break; path.insert(0, parent.name); parentId = parent.parentId;
    }
    return path.join(' / ');
  }
  String? _validateSlugFormat(String slug) {
    final noHyphens = slug.replaceAll('-', '');
    if (noHyphens.isEmpty) return 'Slug cannot consist of only hyphens.';
    if (!v.isAlphanumeric(noHyphens) || !v.isLowercase(noHyphens)) return 'Only lowercase letters, numbers, and hyphens are allowed.';
    if (slug.startsWith('-') || slug.endsWith('-')) return 'Slug cannot start or end with a hyphen.';
    if (slug.contains('--')) return 'Slug cannot contain consecutive hyphens.';
    return null;
  }
  void _syncSlugIfPristine() { if (!_isSlugDirty) _syncGeneratedSlug(); }
  void _syncGeneratedSlug() {
    _lastGeneratedSlug = SlugUtil.slugify(_nameController.text);
    _slugController.value = TextEditingValue(text: _lastGeneratedSlug, selection: TextSelection.collapsed(offset: _lastGeneratedSlug.length));
  }
  void _trackSlugOverride() { _isSlugDirty = _slugController.text.trim() != _lastGeneratedSlug; }
  String? _trimOrNull(String v) { final t = v.trim(); return t.isEmpty ? null : t; }
}
