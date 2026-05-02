import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../store/supplier_products_store.dart';
import 'linked_products_header.dart';
import 'linked_products_list_content.dart';
import 'linked_products_search_bar.dart';

class LinkedProductsCardBody extends StatelessWidget {
  const LinkedProductsCardBody({
    super.key,
    required this.supplierId,
    required this.store,
    required this.searchController,
    required this.onAddProduct,
  });

  final String supplierId;
  final SupplierProductsStore store;
  final TextEditingController searchController;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinkedProductsHeader(store: store, onAddProduct: onAddProduct),
            const Divider(height: 16),
            LinkedProductsSearchBar(
              controller: searchController,
              onChanged: store.setSupplierProductsSearchQuery,
            ),
            Observer(
              builder: (_) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: store.isLoading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(minHeight: 2),
                      )
                    : const SizedBox(height: 12),
              ),
            ),
            LinkedProductsListContent(
              store: store,
              searchController: searchController,
            ),
          ],
        ),
      ),
    );
  }
}
