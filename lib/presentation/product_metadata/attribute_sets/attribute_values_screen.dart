import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_value_dialog.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/attribute_sets/attribute_values_list.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_confirm_delete.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';

class ProductMetadataAttributeOptionsScreen extends StatefulWidget {
  const ProductMetadataAttributeOptionsScreen({super.key, required this.args});
  final AttributeOptionsArgs args;
  @override
  State<ProductMetadataAttributeOptionsScreen> createState() => _ProductMetadataAttributeOptionsScreenState();
}

class _ProductMetadataAttributeOptionsScreenState extends State<ProductMetadataAttributeOptionsScreen> {
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
        leading: BackButton(onPressed: () => Navigator.of(context).pop(_hasChanged)),
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
          : AttributeValuesList(values: ([...item.values]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder))), onEdit: (value) => _openValueDialog(value: value), onDelete: (value) => _deleteValue(item, value)),
    );
  }
  Future<void> _openValueDialog({AttributeValue? value}) async {
    final currentItem = _attributeSet;
    if (currentItem == null) return;
    final valueController = TextEditingController(text: value?.value ?? '');
    final sortController = TextEditingController(text: (value?.sortOrder ?? currentItem.values.length).toString());
    final saved = await showAttributeValueDialog(context, attributeSet: currentItem, value: value, valueController: valueController, sortController: sortController);
    if (!saved) return;
    final payload = AttributeValue(id: value?.id ?? '', attributeSetId: currentItem.id, value: valueController.text.trim(), sortOrder: int.tryParse(sortController.text.trim()) ?? 0, createdAt: value?.createdAt ?? DateTime.now());
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
    final confirmed = await showMetadataDeleteDialog(
      context,
      title: 'Delete value?',
      message: 'Delete "${value.value}" from "${set.name}"? This action cannot be undone.',
    );
    if (!confirmed) return;
    try {
      await _store.deleteAttributeValue(set.id, value.id);
      _hasChanged = true;
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted value "${value.value}".')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(MetadataErrorFormatter.formatActionError(error: error, actionLabel: 'delete value'))));
    }
  }
}
class ProductMetadataAttributeOptionFormScreen extends StatelessWidget {
  const ProductMetadataAttributeOptionFormScreen({super.key, required this.args});
  final AttributeOptionFormArgs args;
  @override
  Widget build(BuildContext context) => ProductMetadataAttributeOptionsScreen(args: AttributeOptionsArgs(attributeId: args.attributeId));
}
