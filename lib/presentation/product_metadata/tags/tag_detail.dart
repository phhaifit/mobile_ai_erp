import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/core/utils/date_formatter.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag_extensions.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';

class ProductMetadataTagDetailScreen extends StatefulWidget {
  const ProductMetadataTagDetailScreen({
    super.key,
    required this.args,
  });

  final TagDetailArgs args;

  @override
  State<ProductMetadataTagDetailScreen> createState() =>
      _ProductMetadataTagDetailScreenState();
}

class _ProductMetadataTagDetailScreenState
    extends State<ProductMetadataTagDetailScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  late Future<void> _loadTagFuture;
  Tag? _tag;

  @override
  void initState() {
    super.initState();
    _loadTagFuture = _loadTag();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadTagFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tag detail')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final tag = _tag;
        if (tag == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tag detail')),
            body: const Center(child: Text('Tag not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tag detail'),
            actions: <Widget>[
              IconButton(
                onPressed: () => _editTag(tag),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit tag',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                tag.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              MetadataDetailSectionCard(
                title: 'Main information',
                children: <Widget>[
                  MetadataDetailRow(
                    label: 'Status',
                    valueChild: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        MetadataStatusChip(
                          label: tag.isActive ? 'Active' : 'Inactive',
                        ),
                      ],
                    ),
                  ),
                  MetadataDetailRow(
                    label: 'Description',
                    value: tag.descriptionOrNull ?? 'Not set',
                  ),
                  MetadataDetailRow(
                    label: 'Created at',
                    value: DateFormatter.formatFull(tag.createdAt),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadTag() async {
    try {
      _tag = await _store.getTagById(widget.args.tagId);
    } catch (_) {
      _tag = null;
    }
  }

  Future<void> _editTag(Tag tag) async {
    final didChange = await ProductMetadataNavigator.openTagForm<bool>(
      context,
      args: TagFormArgs(tagId: tag.id),
    );
    if (didChange == true && mounted) {
      await _loadTag();
      final updatedTag = _tag;
      if (!mounted) {
        return;
      }
      // If tag was deactivated or not found, go back to tags list
      if (updatedTag == null || !updatedTag.isActive) {
        Navigator.of(context).pop(true);
        return;
      }
      // Otherwise, refresh the detail view
      setState(() {
        _loadTagFuture = _loadTag();
      });
    }
  }
}
