// Drop this widget into your existing Product Detail screen.
// Pass the productId and the SupplierStore instance.
//
// Example usage in ProductDetailScreen:
//
//   ProductSupplierSection(
//     productId: product.id,
//     store: getIt<SupplierStore>(),
//   )

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/stores/supplier/supplier_store.dart';
import '../../../domain/supplier/supplier.dart';
import '../widgets/supplier_widgets.dart';

class ProductSupplierSection extends StatefulWidget {
  final String productId;
  final SupplierStore store;

  const ProductSupplierSection({
    super.key,
    required this.productId,
    required this.store,
  });

  @override
  State<ProductSupplierSection> createState() => _ProductSupplierSectionState();
}

class _ProductSupplierSectionState extends State<ProductSupplierSection> {
  @override
  void initState() {
    super.initState();
    widget.store.fetchSuppliersForProduct(widget.productId);
  }

  Future<void> _showAddSupplierDialog() async {
    final unlinked =
        widget.store.getUnlinkedSuppliersForProduct(widget.productId);

    if (unlinked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('All active suppliers are already linked')),
      );
      return;
    }

    Supplier? selected;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          title: const Text('Add Supplier'),
          content: DropdownButtonFormField<Supplier>(
            decoration: InputDecoration(
              labelText: 'Select Supplier',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            hint: const Text('Choose a supplier'),
            value: selected,
            items: unlinked
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(s.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                          if (s.contactName.isNotEmpty)
                            Text(s.contactName,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500])),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (v) => setDialogState(() => selected = v),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed:
                  selected == null ? null : () => Navigator.pop(ctx, selected),
              child: const Text('Add'),
            ),
          ],
        );
      }),
    ).then((result) async {
      if (result is Supplier) {
        await widget.store.linkSupplierToProduct(widget.productId, result.id);
      }
    });
  }

  Future<void> _removeSupplier(Supplier supplier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Supplier'),
        content: Text('Remove "${supplier.name}" from this product?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.store
          .unlinkSupplierFromProduct(widget.productId, supplier.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Suppliers',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: _showAddSupplierDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ],
            ),
            const Divider(height: 16),
            Observer(builder: (_) {
              final linked =
                  widget.store.getSuppliersForProduct(widget.productId);

              if (linked.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'No suppliers linked yet',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                );
              }

              return Column(
                children: linked
                    .map((s) => _SupplierChipTile(
                          supplier: s,
                          onRemove: () => _removeSupplier(s),
                        ))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SupplierChipTile extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onRemove;

  const _SupplierChipTile({required this.supplier, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          supplier.name[0].toUpperCase(),
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(supplier.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: supplier.phone.isNotEmpty
          ? Text(supplier.phone,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(isActive: supplier.isActive),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.link_off_outlined, size: 18),
            onPressed: onRemove,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}
