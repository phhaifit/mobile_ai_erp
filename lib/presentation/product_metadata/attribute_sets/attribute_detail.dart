import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_detail_section_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ProductMetadataAttributeDetailScreen extends StatefulWidget {
  const ProductMetadataAttributeDetailScreen({
    super.key,
    required this.args,
  });

  final AttributeDetailArgs args;

  @override
  State<ProductMetadataAttributeDetailScreen> createState() =>
      _ProductMetadataAttributeDetailScreenState();
}

class _ProductMetadataAttributeDetailScreenState
    extends State<ProductMetadataAttributeDetailScreen> {
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
        final attribute = _store.findAttributeById(widget.args.attributeId);
        if (attribute == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Attribute detail')),
            body: const Center(child: Text('Attribute not found.')),
          );
        }

        final linkedCategories = _store.categoryAttributes
            .where((item) => item.attributeId == attribute.id)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return Scaffold(
          appBar: AppBar(
            title: const Text('Attribute detail'),
            actions: <Widget>[
              IconButton(
                onPressed: () => ProductMetadataNavigator.openAttributeForm(
                  context,
                  args: AttributeFormArgs(attributeId: attribute.id),
                ),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit attribute',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                attribute.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  MetadataStatusChip(label: attribute.valueType.label),
                  if (attribute.isFilterable)
                    const MetadataStatusChip(label: 'Filterable'),
                ],
              ),
              const SizedBox(height: 16),
              MetadataDetailSectionCard(
                title: 'Main information',
                children: <Widget>[
                  MetadataDetailRow(label: 'Code', value: attribute.code),
                  MetadataDetailRow(
                    label: 'Sort order',
                    value: attribute.sortOrder.toString(),
                  ),
                  if (attribute.effectiveUnitLabels.isNotEmpty)
                    MetadataDetailRow(
                      label: 'Units',
                      value: attribute.effectiveUnitLabels.join(', '),
                    ),
                ],
              ),
              MetadataDetailSectionCard(
                title: 'Constraint',
                children: _buildConstraintRows(attribute),
              ),
              MetadataDetailSectionCard(
                title: 'Usage',
                children: <Widget>[
                  if (attribute.valueType.supportsOptions)
                    MetadataDetailRow(
                      label: 'Options',
                      value: _store
                          .optionCountForAttribute(attribute.id)
                          .toString(),
                    ),
                  if (linkedCategories.isEmpty)
                    const Text('Not linked to any category yet.')
                  else
                    ...linkedCategories.map((link) {
                      final category = _store.findCategoryById(link.categoryId);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '${category?.name ?? link.categoryId}'
                          ' - ${link.isRequired ? 'Required' : 'Optional'}'
                          ' - Sort ${link.sortOrder}',
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

  List<Widget> _buildConstraintRows(Attribute attribute) {
    switch (attribute.valueType) {
      case AttributeValueType.dropdown:
      case AttributeValueType.multiselect:
        return <Widget>[
          MetadataDetailRow(
            label: 'Selection mode',
            value: attribute.valueType == AttributeValueType.dropdown
                ? 'Single selection'
                : 'Multiple selection',
          ),
        ];
      case AttributeValueType.text:
        return <Widget>[
          MetadataDetailRow(
            label: 'Min length',
            value: attribute.minLength?.toString() ?? 'Not set',
          ),
          MetadataDetailRow(
            label: 'Max length',
            value: attribute.maxLength?.toString() ?? 'Not set',
          ),
          MetadataDetailRow(
            label: 'Input pattern',
            value: attribute.inputPattern?.trim().isNotEmpty == true
                ? attribute.inputPattern!
                : 'Not set',
          ),
        ];
      case AttributeValueType.number:
        return <Widget>[
          MetadataDetailRow(
            label: 'Min value',
            value: attribute.minValue?.toString() ?? 'Not set',
          ),
          MetadataDetailRow(
            label: 'Max value',
            value: attribute.maxValue?.toString() ?? 'Not set',
          ),
          MetadataDetailRow(
            label: 'Decimal places',
            value: attribute.decimalPlaces?.toString() ?? 'Not set',
          ),
        ];
    }
  }
}
