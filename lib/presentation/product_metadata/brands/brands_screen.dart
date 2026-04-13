import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_extensions.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/brands/brand_list_logic.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_loading_overlay.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_inactive_snackbar.dart';

class ProductMetadataBrandsScreen extends StatefulWidget {
  const ProductMetadataBrandsScreen({super.key});

  @override
  State<ProductMetadataBrandsScreen> createState() =>
      _ProductMetadataBrandsScreenState();
}

class _ProductMetadataBrandsScreenState
    extends State<ProductMetadataBrandsScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  MetadataListQuery _queryState = const MetadataListQuery();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadBrands);
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
        title: const Text('Brands'),
        actions: <Widget>[
          IconButton(
            onPressed: _goToProductMetadataHome,
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Back to Product Metadata',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBrandForm,
        icon: const Icon(Icons.add),
        label: const Text('Add brand'),
      ),
      body: Observer(
        builder: (context) {
          final brands = _store.brands.toList(growable: false);
          final totalPages = _store.brandTotalPages;
          final currentPage = _store.brandCurrentPage;

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: MetadataListControls(
                  searchController: _searchController,
                  onSearchChanged: (value) {
                    _setQueryState(
                      _queryState.copyWith(search: value.trim(), page: 1),
                    );
                    _loadBrands();
                  },
                  searchHint: 'Search by brand name',
                  resultLabel:
                      'Showing ${brands.length} of ${_store.brandTotalItems} brands',
                  hasActiveFilter: _queryState.includeInactive,
                  hasCustomSort: _queryState.hasCustomSort,
                  onOpenFilter: _openFilterSheet,
                  onOpenSort: _openSortSheet,
                ),
              ),
              Expanded(
                child: MetadataLoadingOverlay(
                  isLoading: _store.isLoading,
                  child: brands.isEmpty
                      ? MetadataEmptyState(
                          icon: Icons.workspace_premium_outlined,
                          title: _store.brandTotalItems == 0
                              ? 'No brands yet'
                              : 'No matching brands',
                          message: _store.brandTotalItems == 0
                              ? 'Add your first brand to keep product data consistent.'
                              : 'Try a different search keyword.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                          itemCount: brands.length + (totalPages > 1 ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index >= brands.length) {
                              return MetadataPaginationControls(
                                currentPage: currentPage,
                                totalPages: totalPages,
                                onPrevious: currentPage > 1
                                    ? () {
                                        _setQueryState(
                                          _queryState.copyWith(
                                            page: currentPage - 1,
                                          ),
                                        );
                                        _loadBrands();
                                      }
                                    : null,
                                onNext: currentPage < totalPages
                                    ? () {
                                        _setQueryState(
                                          _queryState.copyWith(
                                            page: currentPage + 1,
                                          ),
                                        );
                                        _loadBrands();
                                      }
                                    : null,
                              );
                            }

                            final brand = brands[index];
                            return MetadataListCard(
                              title: brand.name,
                              leading: Icon(                                
                                Icons.workspace_premium_outlined,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              detailLines: _brandSummary(brand),
                              chips: <Widget>[
                                MetadataStatusChip(
                                  label: brand.isActive ? 'Active' : 'Inactive',
                                ),
                              ],
                              trailing: brand.isActive
                                  ? PopupMenuButton<String>(
                                      onSelected: (value) {
                                        switch (value) {
                                          case 'edit':
                                            _openBrandForm(
                                              args:
                                                  BrandFormArgs(brandId: brand.id),
                                            );
                                            break;
                                          case 'delete':
                                            _deleteBrand(brand);
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) =>
                                          <PopupMenuEntry<String>>[
                                            const PopupMenuItem<String>(
                                              value: 'edit',
                                              child: Text('Edit'),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Text('Deactivate'),
                                            ),
                                          ],
                                    )
                                  : null,
                              onTap: brand.isActive
                                  ? () => _openBrandDetail(brand)
                                  : () => showMetadataInactiveSnackbar(
                                        context,
                                        itemType: 'brand',
                                      ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final includeInactive = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        var tempValue = _queryState.includeInactive;
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
                      'Filter brands',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: tempValue,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include inactive'),
                      onChanged: (value) => setModalState(() {
                        tempValue = value;
                      }),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(tempValue),
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

    if (includeInactive == null || !mounted) {
      return;
    }
    _setQueryState(
      _queryState.copyWith(includeInactive: includeInactive, page: 1),
    );
    await _loadBrands();
  }

  Future<void> _openSortSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sort brands',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                RadioListTile<String>(
                  value: 'name_asc',
                  groupValue: 'name_asc',
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Name (A-Z)'),
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _setQueryState(
                      _queryState.copyWith(
                        sortBy: 'name',
                        sortOrder: 'asc',
                        page: 1,
                      ),
                    );
                    _loadBrands();
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToProductMetadataHome() {
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name ==
              ProductMetadataNavigator.productMetadataHomeRoute ||
          route.isFirst,
    );
  }

  Future<void> _openBrandForm({BrandFormArgs? args}) async {
    final didChange = await ProductMetadataNavigator.openBrandForm<bool>(
      context,
      args: args,
    );
    if (didChange == true && mounted) {
      await _loadBrands();
    }
  }

  Future<void> _openBrandDetail(Brand brand) async {
    await ProductMetadataNavigator.openBrandDetail<void>(
      context,
      args: BrandDetailArgs(brandId: brand.id),
    );
    if (mounted) {
      await _loadBrands();
    }
  }

  List<String> _brandSummary(Brand brand) {
    return <String>[
      if (brand.descriptionOrNull != null) brand.descriptionOrNull!,
    ];
  }

  Future<void> _deleteBrand(Brand brand) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Deactivate brand?'),
              content: Text(
                'Deactivate "${brand.name}"? This brand will be marked as inactive.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Deactivate'),
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
      final previousTotalItems = _store.brandTotalItems;
      await _store.deleteBrand(brand.id);
      final effectiveTotalItems =
          _queryState.includeInactive
              ? previousTotalItems
              : (previousTotalItems > 0 ? previousTotalItems - 1 : 0);
      _queryState = _queryState.copyWith(
        page: resolveBrandPageAfterDelete(
          currentPage: _queryState.page,
          pageSize: _queryState.pageSize,
          totalItems: effectiveTotalItems,
          includeInactive: _queryState.includeInactive,
        ),
      );
      await _loadBrands();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deactivated "${brand.name}".'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _buildFallbackActionErrorMessage(
              error: error,
              actionLabel: 'deactivate brand',
            ),
          ),
        ),
      );
    }
  }

  String _buildFallbackActionErrorMessage({
    required Object error,
    required String actionLabel,
  }) {
    final message = error.toString().trim();
    if (message.isEmpty || message.startsWith('Instance of ')) {
      return 'Couldn\'t $actionLabel. Try again.';
    }
    return message;
  }

  void _setQueryState(MetadataListQuery nextQuery) {
    if (!mounted) {
      return;
    }
    setState(() {
      _queryState = nextQuery;
    });
  }

  Future<void> _loadBrands() => _store.loadBrands(
    page: _queryState.page,
    pageSize: _queryState.pageSize,
    search: _queryState.search,
    includeInactive: _queryState.includeInactive,
  );
}
