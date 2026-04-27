import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_detail_body.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_shell.dart';

class ProductMetadataAttributeDetailScreen extends StatefulWidget {
  const ProductMetadataAttributeDetailScreen({super.key, required this.args});
  final AttributeDetailArgs args;

  @override
  State<ProductMetadataAttributeDetailScreen> createState() =>
      _ProductMetadataAttributeDetailScreenState();
}

class _ProductMetadataAttributeDetailScreenState
    extends State<ProductMetadataAttributeDetailScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  late Future<AttributeSet?> _itemFuture;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _itemFuture = _loadItem();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AttributeSet?>(
      future: _itemFuture,
      builder: (context, snapshot) {
        final item = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return _shell(const Center(child: CircularProgressIndicator()));
        }
        if (item == null) {
          return _shell(const Center(child: Text('Attribute set not found.')));
        }
        return _shell(
          AttributeDetailBody(item: item, onManageValues: () => _manageValues(item)),
          actions: <Widget>[
            IconButton(
              onPressed: () => _editAttributeSet(item),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
            ),
          ],
        );
      },
    );
  }

  Widget _shell(Widget body, {List<Widget>? actions}) => MetadataDetailShell(
      title: 'Attribute set detail',
      hasChanged: _hasChanged,
      body: body,
      actions: actions,
    );

  Future<void> _manageValues(AttributeSet item) async {
    final changed = await ProductMetadataNavigator.openAttributeOptions(
      context,
      args: AttributeOptionsArgs(attributeId: item.id),
    );
    if (changed == true && mounted) {
      _hasChanged = true;
      setState(() => _itemFuture = _loadItem());
    }
  }

  Future<AttributeSet?> _loadItem() async {
    try {
      return await _store.getAttributeSetById(widget.args.attributeId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _editAttributeSet(AttributeSet item) async {
    final changed = await ProductMetadataNavigator.openAttributeForm<bool>(
      context,
      args: AttributeFormArgs(attributeId: item.id),
    );
    if (changed == true && mounted) {
      _hasChanged = true;
      final updatedItem = await _loadItem();
      if (!mounted) return;
      if (updatedItem == null) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() => _itemFuture = Future.value(updatedItem));
    }
  }
}
