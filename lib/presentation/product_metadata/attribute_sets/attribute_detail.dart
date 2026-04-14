import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/date_formatter.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';

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
          return Scaffold(
            appBar: AppBar(
              title: const Text('Attribute set detail'),
              leading: BackButton(
                onPressed: () => Navigator.of(context).pop(_hasChanged),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (item == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Attribute set detail'),
              leading: BackButton(
                onPressed: () => Navigator.of(context).pop(_hasChanged),
              ),
            ),
            body: const Center(child: Text('Attribute set not found.')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Attribute set detail'),
            leading: BackButton(
              onPressed: () => Navigator.of(context).pop(_hasChanged),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () => _editAttributeSet(item),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(item.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              MetadataDetailSectionCard(
                title: 'Main information',
                children: <Widget>[
                  MetadataDetailRow(
                    label: 'Description',
                    value: item.description?.trim().isNotEmpty == true
                        ? item.description!
                        : 'Not set',
                  ),
                  MetadataDetailRow(
                    label: 'Values',
                    valueChild: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.values.length.toString(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        TextButton(
                          onPressed: () async {
                            final changed =
                                await ProductMetadataNavigator.openAttributeOptions(
                                  context,
                                  args: AttributeOptionsArgs(
                                    attributeId: item.id,
                                  ),
                                );
                            if (changed == true && mounted) {
                              _hasChanged = true;
                              setState(() {
                                _itemFuture = _loadItem();
                              });
                            }
                          },
                          child: const Text('Manage'),
                        ),
                      ],
                    ),
                  ),
                  MetadataDetailRow(
                    label: 'Created at',
                    value: DateFormatter.formatFull(item.createdAt),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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
      // Reload the item to get the latest state
      final updatedItem = await _loadItem();
      if (!mounted) {
        return;
      }
      // If attribute set was not found (deleted), go back to list immediately
      if (updatedItem == null) {
        Navigator.of(context).pop(true);
        return;
      }
      // Otherwise, refresh the detail view
      setState(() {
        _itemFuture = _loadItem();
      });
    }
  }
}
