import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/tags/tag_detail_body.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_shell.dart';

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
  bool _hasChanged = false;

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
          return _shell(const Center(child: CircularProgressIndicator()));
        }
        final tag = _tag;
        if (tag == null) {
          return _shell(const Center(child: Text('Tag not found.')));
        }
        return _shell(
          TagDetailBody(tag: tag),
          actions: <Widget>[
            IconButton(
              onPressed: () => _editTag(tag),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit tag',
            ),
          ],
        );
      },
    );
  }

  Widget _shell(Widget body, {List<Widget>? actions}) => MetadataDetailShell(
      title: 'Tag detail',
      hasChanged: _hasChanged,
      body: body,
      actions: actions,
    );

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
      _hasChanged = true;
      await _loadTag();
      final updatedTag = _tag;
      if (!mounted) {
        return;
      }
      if (updatedTag == null) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() {});
    }
  }
}
