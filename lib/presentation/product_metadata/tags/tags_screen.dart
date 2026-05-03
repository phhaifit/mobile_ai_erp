import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
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
import 'package:mobile_ai_erp/presentation/product_metadata/tags/tag_list_body.dart';

class ProductMetadataTagsScreen extends StatefulWidget {
  const ProductMetadataTagsScreen({super.key});
  @override
  State<ProductMetadataTagsScreen> createState() => _ProductMetadataTagsScreenState();
}
class _ProductMetadataTagsScreenState extends State<ProductMetadataTagsScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  MetadataListQuery _queryState = const MetadataListQuery();
  late List<ReactionDisposer> _disposers;
  @override
  void initState() {
    super.initState();
    _disposers = [createMetadataErrorReaction(context: context, errorMessage: () => _store.errorStore.errorMessage, isMounted: () => mounted, actionLabel: 'load tags')];
    Future<void>.microtask(_loadTags);
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
      title: 'Tags',
      addLabel: 'Add tag',
      isLoading: _store.isTagLoading,
      onAdd: _openTagForm,
      controls: MetadataListControls(
        searchController: _searchController,
        onSearchChanged: (v) { _setQuery(_queryState.copyWith(search: v.trim(), page: 1)); _loadTags(); },
        searchHint: 'Search by name',
        resultLabel: 'Showing ${_store.tags.length} of ${_store.tagTotalItems} tags',
        hasCustomSort: _queryState.hasCustomSort,
        onOpenSort: _openSortSheet,
      ),
      child: TagListBody(
        store: _store,
        queryState: _queryState,
        onPageChange: (p) { _setQuery(_queryState.copyWith(page: p)); _loadTags(); },
        onEdit: (t) => _openTagForm(args: TagFormArgs(tagId: t.id)),
        onDelete: _deleteTag,
        onTap: _openTagDetail,
      ),
    ));
  }
  Future<void> _openSortSheet() => showMetadataSortSheet(
    context,
    title: 'Sort tags',
    options: const [defaultMetadataSortOption],
    onSelected: (by, order) {
      _setQuery(_queryState.copyWith(sortBy: by, sortOrder: order, page: 1));
      _loadTags();
    },
  );
  Future<void> _openTagForm({TagFormArgs? args}) async {
    final changed = await ProductMetadataNavigator.openTagForm<bool>(context, args: args);
    if (changed == true && mounted) await _loadTags();
  }
  Future<void> _openTagDetail(Tag tag) async {
    await ProductMetadataNavigator.openTagDetail<void>(context, args: TagDetailArgs(tagId: tag.id));
    if (mounted) await _loadTags();
  }
  Future<void> _deleteTag(Tag tag) async {
    final confirmed = await showMetadataDeleteDialog(context, title: 'Delete tag?', message: 'Delete "${tag.name}"? This action cannot be undone.');
    if (!confirmed) return;
    final prev = _store.tagTotalItems;
    await _store.deleteTag(tag.id);
    _setQuery(_queryState.copyWith(page: resolveMetadataPageAfterDelete(currentPage: _queryState.page, pageSize: _queryState.pageSize, totalItems: prev)));
    await _loadTags();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${tag.name}".')));
  }
  void _setQuery(MetadataListQuery q) { if (mounted) setState(() => _queryState = q); }
  Future<void> _loadTags() => _store.loadTags(page: _queryState.page, pageSize: _queryState.pageSize, search: _queryState.search, sortBy: _queryState.sortBy, sortOrder: _queryState.sortOrder);
}
