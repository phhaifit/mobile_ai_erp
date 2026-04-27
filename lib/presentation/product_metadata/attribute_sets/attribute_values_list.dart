import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';

class AttributeValuesList extends StatelessWidget {
  const AttributeValuesList({
    super.key,
    required this.values,
    required this.onEdit,
    required this.onDelete,
  });

  final List<AttributeValue> values;
  final ValueChanged<AttributeValue> onEdit;
  final ValueChanged<AttributeValue> onDelete;

  @override
  Widget build(BuildContext context) {
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
            onSelected: (action) {
              if (action == 'edit') {
                onEdit(value);
                return;
              }
              onDelete(value);
            },
            itemBuilder: (context) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
              PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
            ],
          ),
        );
      },
    );
  }
}
