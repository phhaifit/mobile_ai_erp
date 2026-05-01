import 'package:flutter/material.dart';

import '../../../domain/entity/supplier/product_summary.dart';

class ProductPickerProductTile extends StatelessWidget {
  const ProductPickerProductTile({
    super.key,
    required this.product,
    required this.isLinked,
    required this.onTap,
  });

  final ProductSummary product;
  final bool isLinked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: isLinked ? 0.52 : 1,
      child: ListTile(
        enabled: !isLinked,
        title: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: _ProductPickerSubtitle(product: product),
        trailing: isLinked
            ? _LinkedBadge(theme: theme)
            : Icon(
                Icons.chevron_right_outlined,
                color: theme.colorScheme.primary,
              ),
        onTap: onTap,
      ),
    );
  }
}

class _ProductPickerSubtitle extends StatelessWidget {
  const _ProductPickerSubtitle({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadataParts = <String>[
      if (product.categoryName?.isNotEmpty ?? false) product.categoryName!,
      if (product.brandName?.isNotEmpty ?? false) product.brandName!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (metadataParts.isNotEmpty)
          Text(
            metadataParts.join(' / '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 4),
        Text(
          'SKU: ${product.sku}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        if (product.barcode?.isNotEmpty ?? false)
          Text(
            'Barcode: ${product.barcode}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
      ],
    );
  }
}

class _LinkedBadge extends StatelessWidget {
  const _LinkedBadge({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 24,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}
