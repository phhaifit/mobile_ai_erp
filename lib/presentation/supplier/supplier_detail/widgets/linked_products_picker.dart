import 'package:flutter/material.dart';

import '../../../../domain/entity/supplier/product_summary.dart';
import '../../product_picker/product_picker_screen.dart';
import '../../store/supplier_products_store.dart';
import 'linked_products_picker_dialog.dart';

Future<void> showLinkedProductsPicker(
  BuildContext context, {
  required SupplierProductsStore store,
  required String supplierId,
}) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => _ProductPickerWithDetails(
        store: store,
        supplierId: supplierId,
      ),
    ),
  );
}

class _ProductPickerWithDetails extends StatefulWidget {
  const _ProductPickerWithDetails({
    required this.store,
    required this.supplierId,
  });

  final SupplierProductsStore store;
  final String supplierId;

  @override
  State<_ProductPickerWithDetails> createState() =>
      _ProductPickerWithDetailsState();
}

class _ProductPickerWithDetailsState extends State<_ProductPickerWithDetails> {
  void _onProductSelected(ProductSummary product) {
    showLinkedProductsPickerDialog(
      context: context,
      store: widget.store,
      supplierId: widget.supplierId,
      product: product,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProductPickerDialog(
      store: widget.store,
      supplierId: widget.supplierId,
      onProductSelected: _onProductSelected,
    );
  }
}
