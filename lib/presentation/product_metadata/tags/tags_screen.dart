import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ProductMetadataTagsScreen extends StatefulWidget {
  const ProductMetadataTagsScreen({super.key});

  @override
  State<ProductMetadataTagsScreen> createState() =>
      _ProductMetadataTagsScreenState();
}

class _ProductMetadataTagsScreenState extends State<ProductMetadataTagsScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => _store.loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ProductMetadataNavigator.openTagForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add tag'),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && !_store.hasLoadedDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_store.tags.isEmpty) {
            return const Center(
              child: Text(
                'No tags yet. Add your first tag to classify products faster.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: _store.tags.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tag = _store.tags[index];
              return MetadataListCard(
                title: tag.name,
                leading: _TagColorDot(colorHex: tag.colorHex),
                detailLines: _tagSummary(tag),
                chips: <Widget>[
                  MetadataStatusChip(label: tag.status.label),
                ],
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        ProductMetadataNavigator.openTagForm(
                          context,
                          args: TagFormArgs(tagId: tag.id),
                        );
                        break;
                      case 'delete':
                        _deleteTag(tag);
                        break;
                    }
                  },
                  itemBuilder: (context) => const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
                onTap: () => ProductMetadataNavigator.openTagDetail(
                  context,
                  args: TagDetailArgs(tagId: tag.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<String> _tagSummary(Tag tag) {
    return <String>[
      if (tag.description != null && tag.description!.trim().isNotEmpty)
        tag.description!.trim(),
      if (tag.colorHex != null && tag.colorHex!.trim().isNotEmpty)
        'Color: ${tag.colorHex}',
      'Sort order: ${tag.sortOrder}',
    ];
  }

  Future<void> _deleteTag(Tag tag) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete tag?'),
              content: Text('Delete "${tag.name}"? This can\'t be undone.'),
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

    if (!confirmed) {
      return;
    }

    try {
      await _store.deleteTag(tag.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${tag.name}".')),
      );
    } catch (error) {
      debugPrint('Failed to delete tag: $error');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t delete tag. Try again.'),
        ),
      );
    }
  }
}

class _TagColorDot extends StatelessWidget {
  const _TagColorDot({required this.colorHex});

  final String? colorHex;

  @override
  Widget build(BuildContext context) {
    final parsedColor = _parseColor(colorHex);
    if (parsedColor == null) {
      return const Icon(Icons.sell_outlined);
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: parsedColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }

  Color? _parseColor(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim().replaceFirst('#', '');
    if (normalized.length != 6) {
      return null;
    }
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) {
      return null;
    }
    return Color(0xFF000000 | parsed);
  }
}
