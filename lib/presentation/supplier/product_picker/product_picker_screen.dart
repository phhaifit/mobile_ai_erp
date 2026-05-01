import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../domain/entity/supplier/product_summary.dart';
import '../store/supplier_products_store.dart';
import 'product_picker_empty_state.dart';
import 'product_picker_results.dart';
import 'product_picker_search_bar.dart';

class ProductPickerDialog extends StatefulWidget {
  const ProductPickerDialog({
    super.key,
    required this.store,
    required this.supplierId,
    this.onProductSelected,
  });

  final SupplierProductsStore store;
  final String supplierId;
  final Function(ProductSummary)? onProductSelected;

  @override
  State<ProductPickerDialog> createState() => _ProductPickerDialogState();
}

class _ProductPickerDialogState extends State<ProductPickerDialog> {
  late final TextEditingController _searchCtrl;
  late final SupplierProductsStore _store;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _store = widget.store;
    _store.searchProducts('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) => _store.searchProducts(query, reset: true);

  Future<void> _nextPage() => _store.nextProductSearchPage();

  Future<void> _previousPage() => _store.previousProductSearchPage();

  void _selectProduct(ProductSummary product) {
    if (widget.onProductSelected != null) {
      widget.onProductSelected!(product);
      return;
    }
    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Product'), elevation: 0),
      body: Column(
        children: [
          ProductPickerSearchBar(
            controller: _searchCtrl,
            onChanged: _onSearch,
            onClear: () {
              _searchCtrl.clear();
              _onSearch('');
            },
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                if (_store.isLoading && _store.availableProducts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_store.availableProducts.isEmpty) {
                  return ProductPickerEmptyState(
                    hasSearchQuery: _searchCtrl.text.isNotEmpty,
                  );
                }
                return ProductPickerResults(
                  products: _store.availableProducts,
                  totalItems: _store.productSearchTotalItems,
                  currentPage: _store.productSearchPage,
                  totalPages: _store.productSearchTotalPages,
                  isLoading: _store.isLoading,
                  supplierId: widget.supplierId,
                  onProductSelected: _selectProduct,
                  onPreviousPage: _previousPage,
                  onNextPage: _nextPage,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
