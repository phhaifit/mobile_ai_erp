import 'package:flutter/material.dart';

import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';

class ProductMetadataAttributeOptionsScreen extends StatefulWidget {
  const ProductMetadataAttributeOptionsScreen({
    super.key,
    required this.args,
  });

  final AttributeOptionsArgs args;

  @override
  State<ProductMetadataAttributeOptionsScreen> createState() =>
      _ProductMetadataAttributeOptionsScreenState();
}

class _ProductMetadataAttributeOptionsScreenState
    extends State<ProductMetadataAttributeOptionsScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  AttributeSet? _attributeSet;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    _attributeSet = await _store.getAttributeSetById(widget.args.attributeId);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final item = _attributeSet;
    return Scaffold(
      appBar: AppBar(
        title: Text(item?.name ?? 'Attribute values'),
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(_hasChanged),
        ),
      ),
      floatingActionButton: item == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openValueDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add value'),
            ),
      body: item == null
          ? const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                final values = [...item.values]
                  ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                if (values.isEmpty) {
                  return const MetadataEmptyState(
                    icon: Icons.list_alt_outlined,
                    title: 'No values',
                    message: 'Add the first value for this attribute set.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: values.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final value = values[index];
                    return MetadataListCard(
                      title: value.value,
                      leading: const Icon(Icons.radio_button_checked),
                      detailLines: <String>['Sort order: ${value.sortOrder}'],
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) async {
                          if (action == 'edit') {
                            await _openValueDialog(value: value);
                            return;
                          }
                          _deleteValue(item, value);
                        },
                        itemBuilder: (context) => const <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                          PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> _openValueDialog({AttributeValue? value}) async {
    final currentItem = _attributeSet;
    if (currentItem == null) return;
    final valueController = TextEditingController(text: value?.value ?? '');
    final sortController = TextEditingController(
      text: (value?.sortOrder ?? currentItem.values.length).toString(),
    );
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(value == null ? 'Add value' : 'Edit value'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: valueController,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      border: OutlineInputBorder(),
                    ),
                    validator: (fieldValue) {
                      if (fieldValue == null || fieldValue.trim().isEmpty) {
                        return 'Value is required.';
                      }
                      final trimmedText = fieldValue.trim().toLowerCase();
                      // Check for duplicates (exclude current value if editing)
                      final existingValues = currentItem.values
                          .where((v) => value == null || v.id != value.id)
                          .map((v) => v.value.toLowerCase())
                          .toList();
                      if (existingValues.contains(trimmedText)) {
                        return 'This value already exists.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: sortController,
                    decoration: const InputDecoration(
                      labelText: 'Sort order',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (fieldValue) {
                      if (fieldValue == null || fieldValue.trim().isEmpty) {
                        return 'Sort order is required.';
                      }
                      if (int.tryParse(fieldValue.trim()) == null) {
                        return 'Must be a number.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ) ??
        false;
    if (!saved) return;
    final payload = AttributeValue(
      id: value?.id ?? '',
      attributeSetId: currentItem.id,
      value: valueController.text.trim(),
      sortOrder: int.tryParse(sortController.text.trim()) ?? 0,
      createdAt: value?.createdAt ?? DateTime.now(),
    );
    if (value == null) {
      await _store.createAttributeValue(payload);
    } else {
      await _store.updateAttributeValue(payload);
    }
    _hasChanged = true;
    await _refresh();
  }

  Future<void> _refresh() async {
    _attributeSet = await _store.getAttributeSetById(widget.args.attributeId);
    if (mounted) setState(() {});
  }

  Future<void> _deleteValue(AttributeSet set, AttributeValue value) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete value?'),
              content: Text(
                'Delete "${value.value}" from "${set.name}"? This action cannot be undone.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    try {
      await _store.deleteAttributeValue(set.id, value.id);
      _hasChanged = true;
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted value "${value.value}".'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MetadataErrorFormatter.formatActionError(
              error: error,
              actionLabel: 'delete value',
            ),
          ),
        ),
      );
    }
  }
}

class ProductMetadataAttributeOptionFormScreen extends StatelessWidget {
  const ProductMetadataAttributeOptionFormScreen({
    super.key,
    required this.args,
  });

  final AttributeOptionFormArgs args;

  @override
  Widget build(BuildContext context) {
    return ProductMetadataAttributeOptionsScreen(
      args: AttributeOptionsArgs(attributeId: args.attributeId),
    );
  }
}
