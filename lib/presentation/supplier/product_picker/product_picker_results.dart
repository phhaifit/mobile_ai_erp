import 'package:flutter/material.dart';

import '../../../domain/entity/supplier/product_summary.dart';
import '../supplier_list/supplier_list_pagination_controls.dart';
import 'product_picker_product_tile.dart';

class ProductPickerResults extends StatelessWidget {
  const ProductPickerResults({
    super.key,
    required this.products,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.isLoading,
    required this.supplierId,
    required this.onProductSelected,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  final List<ProductSummary> products;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final String supplierId;
  final ValueChanged<ProductSummary> onProductSelected;
  final Future<void> Function() onPreviousPage;
  final Future<void> Function() onNextPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isLoading
              ? const LinearProgressIndicator(minHeight: 2)
              : const SizedBox(height: 2),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Showing ${products.length} of $totalItems products',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.74),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: products.length + (totalPages > 1 ? 1 : 0),
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index >= products.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: SupplierListPaginationControls(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPrevious: currentPage > 1 ? onPreviousPage : null,
                    onNext: currentPage < totalPages ? onNextPage : null,
                  ),
                );
              }

              final product = products[index];
              final isLinked = product.isLinkedToSupplier(supplierId);
              return ProductPickerProductTile(
                product: product,
                isLinked: isLinked,
                onTap: isLinked ? null : () => onProductSelected(product),
              );
            },
          ),
        ),
      ],
    );
  }
}
