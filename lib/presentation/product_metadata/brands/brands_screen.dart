import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

enum _BrandSortOption {
  sortOrder('Sort order'),
  nameAsc('Name A-Z'),
  nameDesc('Name Z-A');

  const _BrandSortOption(this.label);

  final String label;
}

class ProductMetadataBrandsScreen extends StatefulWidget {
  const ProductMetadataBrandsScreen({super.key});

  @override
  State<ProductMetadataBrandsScreen> createState() =>
      _ProductMetadataBrandsScreenState();
}

class _ProductMetadataBrandsScreenState
    extends State<ProductMetadataBrandsScreen> {
  static const int _pageSize = 2;

  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  BrandStatus? _statusFilter;
  _BrandSortOption _sortOption = _BrandSortOption.sortOrder;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => _store.loadDashboard());
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
        onPressed: () => ProductMetadataNavigator.openBrandForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add brand'),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && !_store.hasLoadedDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredBrands = _applyFilters(_store.brands.toList());
          final totalPages = _totalPages(filteredBrands.length);
          final currentPage =
              totalPages == 0 ? 1 : _currentPage.clamp(1, totalPages);
          final visibleBrands =
              _pageItems(filteredBrands, currentPage, _pageSize);

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: MetadataListControls(
                  searchController: _searchController,
                  onSearchChanged: (value) => setState(() {
                    _query = value.trim();
                    _currentPage = 1;
                  }),
                  searchHint: 'Search by brand, code, or location',
                  resultLabel:
                      'Showing ${visibleBrands.length} of ${filteredBrands.length} brands',
                  hasActiveFilter: _statusFilter != null,
                  hasCustomSort: _sortOption != _BrandSortOption.sortOrder,
                  onOpenFilter: _openFilterSheet,
                  onOpenSort: _openSortSheet,
                ),
              ),
              Expanded(
                child: filteredBrands.isEmpty
                    ? MetadataEmptyState(
                        icon: Icons.workspace_premium_outlined,
                        title: _store.brands.isEmpty
                            ? 'No brands yet'
                            : 'No matching brands',
                        message: _store.brands.isEmpty
                            ? 'Add your first brand to keep product data consistent.'
                            : 'Try changing your search, filter, or sort order.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount:
                            visibleBrands.length + (totalPages > 1 ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index >= visibleBrands.length) {
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

                          final brand = visibleBrands[index];
                          return MetadataListCard(
                            title: brand.name,
                            leading:
                                const Icon(Icons.workspace_premium_outlined),
                            detailLines: _brandSummary(brand),
                            chips: <Widget>[
                              MetadataStatusChip(label: brand.status.label),
                            ],
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    ProductMetadataNavigator.openBrandForm(
                                      context,
                                      args: BrandFormArgs(brandId: brand.id),
                                    );
                                    break;
                                  case 'delete':
                                    _deleteBrand(brand);
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
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                            onTap: () =>
                                ProductMetadataNavigator.openBrandDetail(
                              context,
                              args: BrandDetailArgs(brandId: brand.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Brand> _applyFilters(List<Brand> brands) {
    final query = _query.toLowerCase();
    final filtered = brands.where((brand) {
      if (_statusFilter != null && brand.status != _statusFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return brand.name.toLowerCase().contains(query) ||
          brand.code.toLowerCase().contains(query) ||
          (brand.displayLocation?.toLowerCase().contains(query) ?? false);
    }).toList();

    filtered.sort((left, right) {
      switch (_sortOption) {
        case _BrandSortOption.sortOrder:
          final orderCompare = left.sortOrder.compareTo(right.sortOrder);
          if (orderCompare != 0) {
            return orderCompare;
          }
          return left.name.toLowerCase().compareTo(right.name.toLowerCase());
        case _BrandSortOption.nameAsc:
          return left.name.toLowerCase().compareTo(right.name.toLowerCase());
        case _BrandSortOption.nameDesc:
          return right.name.toLowerCase().compareTo(left.name.toLowerCase());
      }
    });

    return filtered;
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<BrandStatus?>(
      context: context,
      builder: (context) {
        BrandStatus? tempStatus = _statusFilter;
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
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('All statuses'),
                      trailing:
                          tempStatus == null ? const Icon(Icons.check) : null,
                      onTap: () => setModalState(() {
                        tempStatus = null;
                      }),
                    ),
                    for (final status in BrandStatus.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(status.label),
                        trailing: tempStatus == status
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => setModalState(() {
                          tempStatus = status;
                        }),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(tempStatus),
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

    if (!mounted) {
      return;
    }
    if (selected != null) {
      setState(() {
        _statusFilter = selected;
        _currentPage = 1;
      });
    }
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<_BrandSortOption>(
      context: context,
      builder: (context) {
        _BrandSortOption tempSort = _sortOption;
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
                      'Sort brands',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    for (final option in _BrandSortOption.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(option.label),
                        trailing:
                            tempSort == option ? const Icon(Icons.check) : null,
                        onTap: () => setModalState(() {
                          tempSort = option;
                        }),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(tempSort),
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

    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _sortOption = selected;
      _currentPage = 1;
    });
  }

  int _totalPages(int itemCount) =>
      itemCount == 0 ? 0 : ((itemCount - 1) ~/ _pageSize) + 1;

  void _goToProductMetadataHome() {
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name ==
              ProductMetadataNavigator.productMetadataHomeRoute ||
          route.isFirst,
    );
  }

  List<Brand> _pageItems(List<Brand> items, int page, int pageSize) {
    final start = (page - 1) * pageSize;
    if (start >= items.length) {
      return const <Brand>[];
    }
    final end = (start + pageSize).clamp(0, items.length);
    return items.sublist(start, end);
  }

  List<String> _brandSummary(Brand brand) {
    return <String>[
      'Code: ${brand.code}',
      if (brand.displayLocation != null) 'Location: ${brand.displayLocation}',
      'Sort order: ${brand.sortOrder}',
    ];
  }

  Future<void> _deleteBrand(Brand brand) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete brand?'),
              content: Text('Delete "${brand.name}"? This can\'t be undone.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
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
      await _store.deleteBrand(brand.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${brand.name}".')),
      );
    } catch (error) {
      debugPrint('Failed to delete brand: $error');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t delete brand. Try again.'),
        ),
      );
    }
  }
}
