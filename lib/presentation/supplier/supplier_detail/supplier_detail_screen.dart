import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../domain/supplier/supplier.dart';
import '../../../core/stores/supplier/supplier_store.dart';
import '../supplier_form/supplier_form_screen.dart';
import '../widgets/supplier_widgets.dart';

class SupplierDetailScreen extends StatefulWidget {
  final SupplierStore store;
  final String supplierId;

  const SupplierDetailScreen({
    super.key,
    required this.store,
    required this.supplierId,
  });

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fix: fetch products FOR this supplier (not the other direction)
    widget.store.fetchProductsForSupplier(widget.supplierId);
  }

  Supplier? get _supplier {
    try {
      return widget.store.suppliers
          .firstWhere((s) => s.id == widget.supplierId);
    } catch (_) {
      return null;
    }
  }

  void _openEdit(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SupplierFormScreen(store: widget.store, supplier: supplier),
      ),
    );
  }

  Future<void> _delete(Supplier supplier) async {
    final confirmed = await showConfirmDeleteDialog(context, supplier.name);
    if (confirmed && mounted) {
      await widget.store.deleteSupplier(supplier.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _showAddProductDialog() async {
    final unlinked =
        widget.store.getUnlinkedProductsForSupplier(widget.supplierId);

    if (unlinked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('All products are already linked to this supplier')),
      );
      return;
    }

    MapEntry<String, String>? selected;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Product'),
          content: DropdownButtonFormField<MapEntry<String, String>>(
            decoration: InputDecoration(
              labelText: 'Select Product',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            hint: const Text('Choose a product'),
            value: selected,
            items: unlinked
                .map((entry) => DropdownMenuItem(
                      value: entry,
                      child: Text(entry.value,
                          style: const TextStyle(fontSize: 14)),
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
        ),
      ),
    ).then((result) async {
      if (result is MapEntry<String, String>) {
        await widget.store.linkSupplierToProduct(result.key, widget.supplierId);
      }
    });
  }

  Future<void> _removeProduct(String productId, String productName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Product'),
        content: Text('Remove "$productName" from this supplier?'),
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
          .unlinkSupplierFromProduct(productId, widget.supplierId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final supplier = _supplier;
      if (supplier == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Supplier not found')),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Supplier Detail'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _openEdit(supplier),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _delete(supplier),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeaderCard(
              supplier: supplier,
              onToggleActive: () => widget.store.toggleActive(supplier),
            ),
            const SizedBox(height: 16),
            _InfoCard(supplier: supplier),
            const SizedBox(height: 16),
            _LinkedProductsCard(
              supplierId: widget.supplierId,
              store: widget.store,
              onAddProduct: _showAddProductDialog,
              onRemoveProduct: _removeProduct,
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onToggleActive;
  const _HeaderCard({required this.supplier, required this.onToggleActive});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              supplier.name[0].toUpperCase(),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer),
            ),
          ),
          const SizedBox(height: 12),
          Text(supplier.name,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          StatusBadge(isActive: supplier.isActive),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onToggleActive,
            icon: Icon(supplier.isActive
                ? Icons.block_outlined
                : Icons.check_circle_outline),
            label: Text(supplier.isActive ? 'Deactivate' : 'Activate'),
          ),
        ]),
      ),
    );
  }
}

// ─── Info ─────────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Supplier supplier;
  const _InfoCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Information',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const Divider(height: 20),
            _InfoRow(
                icon: Icons.person_outline,
                label: 'Contact',
                value: supplier.contactName),
            _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: supplier.phone),
            _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: supplier.email),
            _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: supplier.address),
            if (supplier.notes.isNotEmpty)
              _InfoRow(
                  icon: Icons.notes_outlined,
                  label: 'Notes',
                  value: supplier.notes),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 10),
          SizedBox(
              width: 70,
              child: Text(label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ─── Linked Products (fully reactive, with Add + Remove) ─────────────────────

class _LinkedProductsCard extends StatelessWidget {
  final String supplierId;
  final SupplierStore store;
  final VoidCallback onAddProduct;
  final Future<void> Function(String productId, String productName)
      onRemoveProduct;

  const _LinkedProductsCard({
    required this.supplierId,
    required this.store,
    required this.onAddProduct,
    required this.onRemoveProduct,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
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
                Observer(builder: (_) {
                  final count =
                      store.getProductIdsForSupplier(supplierId).length;
                  return Row(children: [
                    Text('Linked Products',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$count',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer)),
                    ),
                  ]);
                }),
                TextButton.icon(
                  onPressed: onAddProduct,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Product'),
                ),
              ],
            ),
            const Divider(height: 16),
            Observer(builder: (_) {
              final productIds = store.getProductIdsForSupplier(supplierId);

              if (productIds.isEmpty) {
                return const EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No products linked',
                  subtitle:
                      'Tap "Add Product" to link products to this supplier',
                );
              }

              return Column(
                children: productIds.map((id) {
                  final name = store.allMockProducts[id] ?? id;
                  return _ProductTile(
                    productId: id,
                    name: name,
                    onRemove: () => onRemoveProduct(id, name),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final String productId;
  final String name;
  final VoidCallback onRemove;

  const _ProductTile({
    required this.productId,
    required this.name,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(Icons.inventory_2_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.onSecondaryContainer),
      ),
      title: Text(name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(productId,
          style: TextStyle(fontSize: 11, color: Colors.grey[400])),
      trailing: IconButton(
        icon: const Icon(Icons.link_off_outlined, size: 18),
        tooltip: 'Remove',
        onPressed: onRemove,
      ),
    );
  }
}
