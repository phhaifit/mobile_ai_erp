import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../core/stores/supplier/supplier_store.dart';
import '../supplier_detail/supplier_detail_screen.dart';
import '../supplier_form/supplier_form_screen.dart';
import '../widgets/supplier_widgets.dart';

class SupplierListScreen extends StatefulWidget {
  final SupplierStore store;

  const SupplierListScreen({super.key, required this.store});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.store.fetchSuppliers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(String supplierId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupplierDetailScreen(
          store: widget.store,
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
      await widget.store.deleteSupplier(supplierId);
      if (widget.store.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.store.errorMessage!)),
        );
      }
    }
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
          _SearchBar(
            controller: _searchController,
            onChanged: widget.store.setSearchQuery,
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                if (widget.store.isLoading && widget.store.suppliers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final suppliers = widget.store.filteredSuppliers;

                if (suppliers.isEmpty) {
                  return EmptyState(
                    icon: Icons.business_outlined,
                    title: widget.store.searchQuery.isEmpty
                        ? 'No suppliers yet'
                        : 'No results found',
                    subtitle: widget.store.searchQuery.isEmpty
                        ? 'Tap + to add your first supplier'
                        : 'Try a different search term',
                  );
                }

                return RefreshIndicator(
                  onRefresh: widget.store.fetchSuppliers,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: suppliers.length,
                    itemBuilder: (_, i) {
                      final s = suppliers[i];
                      return SupplierCard(
                        supplier: s,
                        onTap: () => _openDetail(s.id),
                        onEdit: () => _openEdit(s.id),
                        onDelete: () => _delete(s.id, s.name),
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

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search by name, phone, email…',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }
}
