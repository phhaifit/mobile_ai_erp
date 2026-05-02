import 'package:flutter/material.dart';

import '../../store/supplier_products_store.dart';
import 'linked_products_card_body.dart';
import 'linked_products_picker.dart';

class LinkedProductsCard extends StatefulWidget {
  const LinkedProductsCard({
    super.key,
    required this.supplierId,
    required this.store,
  });

  final String supplierId;
  final SupplierProductsStore store;

  @override
  State<LinkedProductsCard> createState() => _LinkedProductsCardState();
}

class _LinkedProductsCardState extends State<LinkedProductsCard> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddProductDialog(BuildContext context) {
    return showLinkedProductsPicker(
      context,
      store: widget.store,
      supplierId: widget.supplierId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LinkedProductsCardBody(
      supplierId: widget.supplierId,
      store: widget.store,
      searchController: _searchController,
      onAddProduct: () => _showAddProductDialog(context),
    );
  }
}
