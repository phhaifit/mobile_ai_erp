import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../store/supplier_store.dart';
import '../store/supplier_products_store.dart';
import '../supplier_detail/supplier_detail_screen.dart';
import '../supplier_form/supplier_form_screen.dart';
import '../widgets/supplier_card.dart';
import '../widgets/supplier_widgets.dart';
import 'supplier_list_controls.dart';
import 'supplier_list_filter_sheet.dart';
import 'supplier_list_models.dart';
import 'supplier_list_pagination_controls.dart';
import 'supplier_list_sort_sheet.dart';

class SupplierListScreen extends StatefulWidget {
  final SupplierStore store;
  final SupplierProductsStore productsStore;

  const SupplierListScreen({
    super.key,
    required this.store,
    required this.productsStore,
  });

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final _searchController = TextEditingController();
  SupplierProductsFilter _productsFilter = SupplierProductsFilter.all;
  SupplierSortOption _sortOption = SupplierSortOption.defaultOrder;

  @override
  void initState() {
    super.initState();
    widget.store.setSort(sortBy: 'name', sortOrder: 'asc');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilter => _productsFilter != SupplierProductsFilter.all;

  void _openDetail(String supplierId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierDetailScreen(
          store: widget.store,
          productsStore: widget.productsStore,
          supplierId: supplierId,
        ),
      ),
    );
  }

  void _openCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierFormScreen(store: widget.store),
      ),
    );
  }

  void _openEdit(String supplierId) {
    final supplier =
        widget.store.suppliers.firstWhere((s) => s.id == supplierId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SupplierFormScreen(store: widget.store, supplier: supplier),
      ),
    );
  }

  Future<void> _delete(String supplierId, String name) async {
    final confirmed = await showConfirmDeleteDialog(context, name);
    if (confirmed && mounted) {
      final success = await widget.store.deleteSupplier(supplierId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted supplier "$name"'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.store.errorMessage ?? 'Failed to delete supplier'),
            ),
          );
          widget.store.errorMessage = null;
        }
      }
    }
  }

  Future<void> _openFilterSheet() async {
    final result = await showSupplierFilterSheet(
      context,
      current: _productsFilter,
    );
    if (result == null || !mounted) return;
    setState(() => _productsFilter = result.productsFilter);
    await widget.store.setFilters(hasProducts: result.hasProducts);
  }

  Future<void> _openSortSheet() async {
    final result = await showSupplierSortSheet(
      context,
      currentSort: _sortOption,
    );
    if (result == null || !mounted) return;
    setState(() => _sortOption = result);
    await widget.store.setSort(sortBy: 'name', sortOrder: 'asc');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Observer(
              builder: (_) {
                if (widget.store.isLoading && widget.store.suppliers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final suppliers = widget.store.suppliers;
                final resultLabel =
                    'Showing ${suppliers.length} of ${widget.store.totalItems} suppliers';

                return RefreshIndicator(
                  onRefresh: widget.store.fetchSuppliers,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: suppliers.isEmpty
                        ? 2
                        : suppliers.length + (widget.store.totalPages > 1 ? 2 : 1),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return SupplierListControls(
                          searchController: _searchController,
                          onSearchChanged: widget.store.setSearchQuery,
                          resultLabel: resultLabel,
                          hasCustomSort: false,
                          onOpenFilter: _openFilterSheet,
                          onOpenSort: _openSortSheet,
                        );
                      }
                      if (suppliers.isEmpty) {
                        return EmptyState(
                          icon: Icons.business_outlined,
                          title: widget.store.searchQuery.isEmpty
                              ? 'No suppliers yet'
                              : 'No matching suppliers',
                          subtitle: widget.store.searchQuery.isEmpty && !_hasActiveFilter
                              ? 'Tap + to add your first supplier'
                              : 'Try changing your search or filter.',
                        );
                      }

                      final supplierIndex = i - 1;
                      if (supplierIndex >= suppliers.length) {
                        return SupplierListPaginationControls(
                          currentPage: widget.store.currentPage,
                          totalPages: widget.store.totalPages,
                          onPrevious: widget.store.hasPreviousPage
                              ? widget.store.previousPage
                              : null,
                          onNext: widget.store.hasNextPage ? widget.store.nextPage : null,
                        );
                      }

                      final supplier = suppliers[supplierIndex];
                      return SupplierCard(
                        supplier: supplier,
                        onTap: () => _openDetail(supplier.id),
                        onEdit: () => _openEdit(supplier.id),
                        onDelete: () => _delete(supplier.id, supplier.name),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        tooltip: 'Add Supplier',
        child: const Icon(Icons.add),
      ),
    );
  }
}
