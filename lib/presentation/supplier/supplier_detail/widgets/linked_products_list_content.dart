import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../domain/entity/supplier/supplier_product_link.dart';
import '../../store/supplier_products_store.dart';
import '../../supplier_list/supplier_list_pagination_controls.dart';
import '../../widgets/supplier_widgets.dart';
import 'linked_product_tile.dart';
import 'linked_products_edit_dialog.dart';
import 'linked_products_unlink_dialog.dart';

class LinkedProductsListContent extends StatelessWidget {
  const LinkedProductsListContent({
    super.key,
    required this.store,
    required this.searchController,
  });

  final SupplierProductsStore store;
  final TextEditingController searchController;

  Future<void> _editLink(BuildContext context, SupplierProductLink link) {
    return showLinkedProductsEditDialog(context: context, store: store, link: link);
  }

  Future<void> _removeLink(
    BuildContext context,
    SupplierProductLink link,
  ) async {
    final confirmed = await showConfirmUnlinkProductDialog(
      context,
      link.productName,
    );
    if (!confirmed || !context.mounted) return;
    final success = await store.removeProductFromSupplier(
      link.productId,
      link.supplierId,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Unlinked "${link.productName}"'
              : store.errorMessage ?? 'Failed to unlink product',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final theme = Theme.of(context);
        if (store.supplierProducts.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            title: searchController.text.trim().isEmpty
                ? 'No products linked'
                : 'No matching products',
            subtitle: searchController.text.trim().isEmpty
                ? 'Products linked to this supplier will appear here'
                : 'Try a different search term.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Showing ${store.supplierProducts.length} of ${store.supplierProductsTotalItems} products',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.74),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ...store.supplierProducts.map(
              (link) => LinkedProductTile(
                link: link,
                onEdit: () => _editLink(context, link),
                onRemove: () => _removeLink(context, link),
              ),
            ),
            if (store.supplierProductsTotalPages > 1)
              SupplierListPaginationControls(
                currentPage: store.supplierProductsPage,
                totalPages: store.supplierProductsTotalPages,
                onPrevious: store.supplierProductsPage > 1
                    ? store.previousSupplierProductsPage
                    : null,
                onNext: store.supplierProductsPage < store.supplierProductsTotalPages
                    ? store.nextSupplierProductsPage
                    : null,
              ),
          ],
        );
      },
    );
  }
}
