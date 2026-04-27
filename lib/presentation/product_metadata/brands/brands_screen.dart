import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
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
import 'package:mobile_ai_erp/presentation/product_metadata/brands/brand_list_body.dart';

class ProductMetadataBrandsScreen extends StatefulWidget {
  const ProductMetadataBrandsScreen({super.key});
  @override
  State<ProductMetadataBrandsScreen> createState() => _ProductMetadataBrandsScreenState();
}
class _ProductMetadataBrandsScreenState extends State<ProductMetadataBrandsScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  MetadataListQuery _queryState = const MetadataListQuery();
  late List<ReactionDisposer> _disposers;
  @override
  void initState() {
    super.initState();
    _disposers = [createMetadataErrorReaction(context: context, errorMessage: () => _store.errorStore.errorMessage, isMounted: () => mounted, actionLabel: 'load brands')];
    Future<void>.microtask(_loadBrands);
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
      title: 'Brands',
      addLabel: 'Add brand',
      isLoading: _store.isBrandLoading,
      onAdd: _openBrandForm,
      controls: MetadataListControls(
        searchController: _searchController,
        onSearchChanged: (v) { _setQuery(_queryState.copyWith(search: v.trim(), page: 1)); _loadBrands(); },
        searchHint: 'Search by name',
        resultLabel: 'Showing ${_store.brands.length} of ${_store.brandTotalItems} brands',
        hasCustomSort: _queryState.hasCustomSort,
        onOpenSort: _openSortSheet,
      ),
      child: BrandListBody(
        store: _store,
        queryState: _queryState,
        onPageChange: (p) { _setQuery(_queryState.copyWith(page: p)); _loadBrands(); },
        onEdit: (b) => _openBrandForm(args: BrandFormArgs(brandId: b.id)),
        onDelete: _deleteBrand,
        onTap: _openBrandDetail,
      ),
    ));
  }
  Future<void> _openSortSheet() => showMetadataSortSheet(
    context,
    title: 'Sort brands',
    options: const [defaultMetadataSortOption],
    onSelected: (by, order) {
      _setQuery(_queryState.copyWith(sortBy: by, sortOrder: order, page: 1));
      _loadBrands();
    },
  );
  Future<void> _openBrandForm({BrandFormArgs? args}) async {
    final changed = await ProductMetadataNavigator.openBrandForm<bool>(context, args: args);
    if (changed == true && mounted) await _loadBrands();
  }
  Future<void> _openBrandDetail(Brand brand) async {
    await ProductMetadataNavigator.openBrandDetail<void>(context, args: BrandDetailArgs(brandId: brand.id));
    if (mounted) await _loadBrands();
  }
  Future<void> _deleteBrand(Brand brand) async {
    final confirmed = await showMetadataDeleteDialog(context, title: 'Delete brand?', message: 'Delete "${brand.name}"? This action cannot be undone.');
    if (!confirmed) return;
    final prev = _store.brandTotalItems;
    await _store.deleteBrand(brand.id);
    _setQuery(_queryState.copyWith(page: resolveMetadataPageAfterDelete(currentPage: _queryState.page, pageSize: _queryState.pageSize, totalItems: prev)));
    await _loadBrands();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted "${brand.name}".')));
  }
  void _setQuery(MetadataListQuery q) { if (mounted) setState(() => _queryState = q); }
  Future<void> _loadBrands() => _store.loadBrands(page: _queryState.page, pageSize: _queryState.pageSize, search: _queryState.search, sortBy: _queryState.sortBy, sortOrder: _queryState.sortOrder);
}
