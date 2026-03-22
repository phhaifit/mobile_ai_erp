import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_color_utils.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

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

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => _store.loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final tag = _store.findTagById(widget.args.tagId);
        if (tag == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tag detail')),
            body: const Center(child: Text('Tag not found.')),
          );
        }
        final tagColor = tryParseHexColor(tag.colorHex);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tag detail'),
            actions: <Widget>[
              IconButton(
                onPressed: () => ProductMetadataNavigator.openTagForm(
                  context,
                  args: TagFormArgs(tagId: tag.id),
                ),
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
                        MetadataStatusChip(label: tag.status.label),
                      ],
                    ),
                  ),
                  if (tag.colorHex?.trim().isNotEmpty == true)
                    MetadataDetailRow(
                      label: 'Color',
                      valueChild: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          MetadataStatusChip(
                            label: tag.colorHex!,
                            foregroundColor: tagColor == null
                                ? null
                                : readableForegroundFor(
                                    softenedColor(tagColor),
                                  ),
                            backgroundColor: tagColor == null
                                ? null
                                : softenedColor(tagColor),
                          ),
                        ],
                      ),
                    ),
                  if (tag.description != null && tag.description!.isNotEmpty)
                    MetadataDetailRow(
                      label: 'Description',
                      value: tag.description!,
                    ),
                  if (tag.colorHex?.trim().isNotEmpty != true)
                    const MetadataDetailRow(
                      label: 'Color',
                      value: 'Not set',
                    ),
                  MetadataDetailRow(
                    label: 'Sort order',
                    value: tag.sortOrder.toString(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
