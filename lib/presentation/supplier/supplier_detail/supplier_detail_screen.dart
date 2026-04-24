import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../domain/entity/supplier/supplier.dart';
import '../store/supplier_store.dart';
import '../store/supplier_products_store.dart';
import '../supplier_form/supplier_form_screen.dart';
import '../widgets/supplier_widgets.dart' show showConfirmDeleteDialog;
import 'widgets/supplier_header_card.dart';
import 'widgets/supplier_info_card.dart';
import 'widgets/linked_products_card.dart';

class SupplierDetailScreen extends StatefulWidget {
  final SupplierStore store;
  final SupplierProductsStore productsStore;
  final String supplierId;

  const SupplierDetailScreen({
    super.key,
    required this.store,
    required this.productsStore,
    required this.supplierId,
  });

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.store.loadSupplierById(widget.supplierId);
    widget.productsStore.resetSupplierProductsView();
    widget.productsStore.loadSupplierProducts(widget.supplierId);
  }

  void _openEdit(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierFormScreen(store: widget.store, supplier: supplier),
      ),
    );
  }

  Future<void> _delete(Supplier supplier) async {
    final confirmed = await showConfirmDeleteDialog(context, supplier.name);
    if (confirmed && mounted) {
      final success = await widget.store.deleteSupplier(supplier.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted supplier "${supplier.name}"'),
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context);
          });
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

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final supplier = widget.store.currentSupplier;

      if (supplier == null) {
        if (widget.store.isLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
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
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SupplierHeaderCard(
              supplier: supplier,
              onDelete: () => _delete(supplier),
            ),
            const SizedBox(height: 16),
            SupplierInfoCard(supplier: supplier),
            const SizedBox(height: 16),
            LinkedProductsCard(
              supplierId: supplier.id,
              store: widget.productsStore,
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }
}
