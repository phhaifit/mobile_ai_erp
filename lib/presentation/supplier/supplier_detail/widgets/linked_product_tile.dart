import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/price_formatter.dart';
import 'package:mobile_ai_erp/domain/entity/supplier/supplier_product_link.dart';

class LinkedProductTile extends StatelessWidget {
  const LinkedProductTile({
    super.key,
    required this.link,
    required this.onEdit,
    required this.onRemove,
  });

  final SupplierProductLink link;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: colors.secondaryContainer,
            child: Icon(
              Icons.inventory_2_outlined,
              size: 16,
              color: colors.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Text(
                            link.productName,
                            style: textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (link.isPrimary)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Primary',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _ActionsMenu(onEdit: onEdit, onRemove: onRemove),
                  ],
                ),
                const SizedBox(height: 6),
                _MetaTable(link: link),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({required this.onEdit, required this.onRemove});

  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Action>(
      iconSize: 18,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        if (action == _Action.edit) onEdit();
        if (action == _Action.unlink) onRemove();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _Action.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 16),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _Action.unlink,
          child: Row(
            children: [
              Icon(Icons.link_off_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Text('Unlink',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}

enum _Action { edit, unlink }

class _MetaTable extends StatelessWidget {
  const _MetaTable({required this.link});

  final SupplierProductLink link;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      if (link.productSku != null) ('SKU', link.productSku!),
      if (link.productBarcode != null && link.productBarcode!.isNotEmpty)
        ('Barcode', link.productBarcode!),
      if (link.supplierSku != null) ('Supplier SKU', link.supplierSku!),
      if (link.costPrice != null)
        ('Cost', PriceFormatter.formatPriceWithThousands(link.costPrice!)),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows.map((r) => _MetaRow(label: r.$1, value: r.$2)).toList(),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurface.withOpacity(0.4),
                letterSpacing: 0.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
