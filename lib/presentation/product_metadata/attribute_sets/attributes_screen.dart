import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/logic/metadata_pagination_logic.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_confirm_delete.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_reaction.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_scaffold.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_sort_sheet.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_set_list_body.dart';

class ProductMetadataAttributesScreen extends StatefulWidget {
  const ProductMetadataAttributesScreen({super.key, this.args = const AttributesArgs()});
  final AttributesArgs args;
  @override
  State<ProductMetadataAttributesScreen> createState() => _ProductMetadataAttributesScreenState();
}
class _ProductMetadataAttributesScreenState extends State<ProductMetadataAttributesScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  MetadataListQuery _queryState = const MetadataListQuery();
  late List<ReactionDisposer> _disposers;
  @override
  void initState() {
    super.initState();
    _disposers = [createMetadataErrorReaction(context: context, errorMessage: () => _store.errorStore.errorMessage, isMounted: () => mounted, actionLabel: 'load attribute sets')];
    Future<void>.microtask(_loadAttributeSets);
  }
  @override
  void dispose() {
    for (final d in _disposers) {
      d();
    }
    _searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) => MetadataListScaffold(
      title: 'Attribute sets',
      addLabel: 'Add attribute set',
      isLoading: _store.isAttributeSetLoading,
      onAdd: () async {
        final changed = await ProductMetadataNavigator.openAttributeForm(context);
        if (changed == true) _loadAttributeSets();
      },
      controls: MetadataListControls(
        searchController: _searchController,
        onSearchChanged: (v) { _setQuery(_queryState.copyWith(search: v.trim(), page: 1)); _loadAttributeSets(); },
        searchHint: 'Search by name',
        resultLabel: 'Showing ${_store.attributeSets.length} of ${_store.attributeSetTotalItems} attribute sets',
        hasCustomSort: _queryState.hasCustomSort,
        onOpenSort: _openSortSheet,
      ),
      child: AttributeSetListBody(
        store: _store,
        searchQuery: _queryState.search,
        currentPage: _store.attributeSetCurrentPage,
        totalPages: _store.attributeSetTotalPages,
        onPageChange: (p) { _setQuery(_queryState.copyWith(page: p)); _loadAttributeSets(); },
        onEdit: (item) async {
          final changed = await ProductMetadataNavigator.openAttributeForm(context, args: AttributeFormArgs(attributeId: item.id));
          if (changed == true) _loadAttributeSets();
        },
        onDelete: _deleteAttributeSet,
        onTap: (item) async {
          await ProductMetadataNavigator.openAttributeDetail(context, args: AttributeDetailArgs(attributeId: item.id));
          if (mounted) await _loadAttributeSets();
        },
      ),
    ));
  }
  Future<void> _openSortSheet() => showMetadataSortSheet(
    context,
    title: 'Sort attribute sets',
    options: const [defaultMetadataSortOption],
    onSelected: (by, order) {
      _setQuery(_queryState.copyWith(sortBy: by, sortOrder: order, page: 1));
      _loadAttributeSets();
    },
  );
  Future<void> _deleteAttributeSet(AttributeSet item) async {
    final confirmed = await showMetadataDeleteDialog(context, title: 'Delete attribute set?', message: 'Delete "${item.name}"? This will also delete all its associated values. This action cannot be undone.');
    if (!confirmed) return;
    final prev = _store.attributeSetTotalItems;
    await _store.deleteAttributeSet(item.id);
    _setQuery(_queryState.copyWith(page: resolveMetadataPageAfterDelete(currentPage: _queryState.page, pageSize: _queryState.pageSize, totalItems: prev)));
    await _loadAttributeSets();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${item.name}".')));
  }
  void _setQuery(MetadataListQuery q) { if (mounted) setState(() => _queryState = q); }
  Future<void> _loadAttributeSets() => _store.loadAttributeSets(page: _queryState.page, pageSize: _queryState.pageSize, search: _queryState.search, sortBy: _queryState.sortBy, sortOrder: _queryState.sortOrder);
}
