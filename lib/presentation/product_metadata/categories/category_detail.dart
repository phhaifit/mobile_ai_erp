import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ProductMetadataCategoryDetailScreen extends StatefulWidget {
  const ProductMetadataCategoryDetailScreen({
    super.key,
    required this.args,
  });

  final CategoryDetailArgs args;

  @override
  State<ProductMetadataCategoryDetailScreen> createState() =>
      _ProductMetadataCategoryDetailScreenState();
}

class _ProductMetadataCategoryDetailScreenState
    extends State<ProductMetadataCategoryDetailScreen> {
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
        final category = _store.findCategoryById(widget.args.categoryId);
        if (category == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Category detail')),
            body: const Center(child: Text('Category not found.')),
          );
        }
        final parent = _store.findCategoryById(category.parentId);
        final attributeLinks =
            _store.categoryAttributesForCategory(category.id);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Category detail'),
            actions: <Widget>[
              IconButton(
                onPressed: () => ProductMetadataNavigator.openCategoryForm(
                  context,
                  args: CategoryFormArgs(categoryId: category.id),
                ),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit category',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                category.name,
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
                        MetadataStatusChip(label: category.status.label),
                      ],
                    ),
                  ),
                  MetadataDetailRow(label: 'Code', value: category.code),
                  MetadataDetailRow(label: 'Slug', value: category.slug),
                  MetadataDetailRow(
                    label: 'Parent',
                    value: parent?.name ?? 'Top-level category',
                  ),
                  MetadataDetailRow(
                    label: 'Sort order',
                    value: category.sortOrder.toString(),
                  ),
                  MetadataDetailRow(
                    label: 'Description',
                    value: category.description?.trim().isNotEmpty == true
                        ? category.description!
                        : 'Not set',
                  ),
                ],
              ),
              MetadataDetailSectionCard(
                title: 'Media',
                children: <Widget>[
                  MetadataDetailRow(
                    label: 'Cover image URL',
                    value: category.coverImageUrl?.trim().isNotEmpty == true
                        ? category.coverImageUrl!
                        : 'Not set',
                  ),
                ],
              ),
              MetadataDetailSectionCard(
                title: 'Linked attributes',
                children: <Widget>[
                  if (attributeLinks.isEmpty)
                    const Text('No linked attributes yet.')
                  else
                    ...attributeLinks.map((link) {
                      final attribute =
                          _store.findAttributeById(link.attributeId);
                      final name = attribute?.name ?? link.attributeId;
                      final code = attribute?.code ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('$name${code.isEmpty ? '' : ' ($code)'}'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                MetadataStatusChip(
                                  label:
                                      link.isRequired ? 'Required' : 'Optional',
                                ),
                                MetadataStatusChip(
                                  label: 'Sort order: ${link.sortOrder}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
