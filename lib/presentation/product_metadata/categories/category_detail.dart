import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_detail_body.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_detail_state_scaffold.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/category_view_mode.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';

class ProductMetadataCategoryDetailScreen extends StatefulWidget {
  const ProductMetadataCategoryDetailScreen({super.key, required this.args});
  final CategoryDetailArgs args;
  @override
  State<ProductMetadataCategoryDetailScreen> createState() => _ProductMetadataCategoryDetailScreenState();
}

class _ProductMetadataCategoryDetailScreenState extends State<ProductMetadataCategoryDetailScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  late Future<void> _loadCategoryFuture;
  Category? _category;
  Category? _parent;
  bool _hasChanged = false;
  @override
  void initState() {
    super.initState();
    _loadCategoryFuture = _loadCategory();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadCategoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CategoryDetailStateScaffold(hasChanged: _hasChanged, body: const Center(child: CircularProgressIndicator()));
        }
        final category = _category;
        if (category == null) {
          return CategoryDetailStateScaffold(hasChanged: _hasChanged, body: const Center(child: Text('Category not found.')));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Category detail'),
            leading: BackButton(onPressed: () => Navigator.of(context).pop(_hasChanged)),
            actions: <Widget>[
              IconButton(
                onPressed: () => _editCategory(category),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit category',
              ),
            ],
          ),
          body: CategoryDetailBody(
            category: category,
            parent: _parent,
            onViewChildren: (category.childrenCount ?? 0) > 0 ? () => _openChildrenTree(category) : null,
          ),
        );
      },
    );
  }
  Future<void> _loadCategory() async {
    try {
      _category = await _store.getCategoryById(widget.args.categoryId);
      final parentId = _category?.parentId;
      if (parentId != null && parentId.isNotEmpty) {
        try {
          _parent = await _store.getCategoryById(parentId);
        } catch (_) {
          _parent = null;
        }
      }
    } catch (_) {
      _category = null;
      _parent = null;
    }
  }
  Future<void> _editCategory(Category category) async {
    final didChange = await ProductMetadataNavigator.openCategoryForm<bool>(context, args: CategoryFormArgs(categoryId: category.id));
    if (didChange == true && mounted) {
      _hasChanged = true;
      await _loadCategory();
      if (!mounted) return;
      if (_category == null) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() {});
    }
  }
  Future<void> _openChildrenTree(Category category) async {
    await ProductMetadataNavigator.openCategories<bool>(
      context,
      args: CategoriesArgs(
        initialViewMode: CategoryViewMode.tree,
        initialTreePath: <Category>[category],
      ),
    );
  }
}
