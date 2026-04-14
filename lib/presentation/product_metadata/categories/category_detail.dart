import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/date_formatter.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';

class ProductMetadataCategoryDetailScreen extends StatefulWidget {
  const ProductMetadataCategoryDetailScreen({super.key, required this.args});

  final CategoryDetailArgs args;

  @override
  State<ProductMetadataCategoryDetailScreen> createState() =>
      _ProductMetadataCategoryDetailScreenState();
}

class _ProductMetadataCategoryDetailScreenState
    extends State<ProductMetadataCategoryDetailScreen> {
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
          return Scaffold(
            appBar: AppBar(
              title: const Text('Category detail'),
              leading: BackButton(
                onPressed: () => Navigator.of(context).pop(_hasChanged),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final category = _category;
        if (category == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Category detail'),
              leading: BackButton(
                onPressed: () => Navigator.of(context).pop(_hasChanged),
              ),
            ),
            body: const Center(child: Text('Category not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Category detail'),
            leading: BackButton(
              onPressed: () => Navigator.of(context).pop(_hasChanged),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () => _editCategory(category),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit category',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                category.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              MetadataDetailSectionCard(
                title: 'Main information',
                children: <Widget>[
                  MetadataDetailRow(label: 'Slug', value: category.slug),
                  MetadataDetailRow(
                    label: 'Parent',
                    value: _parent?.name ?? 'Top-level category',
                  ),
                  MetadataDetailRow(
                    label: 'Description',
                    value: category.description?.trim().isNotEmpty == true
                        ? category.description!
                        : 'Not set',
                  ),
                  MetadataDetailRow(
                    label: 'Created at',
                    value: DateFormatter.formatFull(category.createdAt),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadCategory() async {
    try {
      _category = await _store.getCategoryById(widget.args.categoryId);
      await _store.loadCategoryTree();
      final parentId = _category?.parentId;
      if (parentId != null && parentId.isNotEmpty) {
        _parent = _store.categoryTree.cast<Category?>().firstWhere(
          (item) => item?.id == parentId,
          orElse: () => null,
        );
      }
    } catch (_) {
      _category = null;
      _parent = null;
    }
  }

  Future<void> _editCategory(Category category) async {
    final didChange = await ProductMetadataNavigator.openCategoryForm<bool>(
      context,
      args: CategoryFormArgs(categoryId: category.id),
    );
    if (didChange == true && mounted) {
      _hasChanged = true;
      // Reload the category to get the latest state
      await _loadCategory();
      if (!mounted) {
        return;
      }
      // If category was not found (deleted), go back to tree immediately
      if (_category == null) {
        Navigator.of(context).pop(true);
        return;
      }
      // Otherwise, refresh the detail view
      setState(() {
        _loadCategoryFuture = _loadCategory();
      });
    }
  }
}
