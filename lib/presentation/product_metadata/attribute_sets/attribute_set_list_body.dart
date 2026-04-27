import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';

class AttributeSetListBody extends StatelessWidget {
  const AttributeSetListBody({
    super.key,
    required this.store,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  final ProductMetadataStore store;
  final int currentPage;
  final int totalPages;
  final void Function(int page) onPageChange;
  final void Function(AttributeSet item) onEdit;
  final void Function(AttributeSet item) onDelete;
  final void Function(AttributeSet item) onTap;

  @override
  Widget build(BuildContext context) {
    final items = store.attributeSets.toList(growable: false);

    if (items.isEmpty) {
      return MetadataEmptyState(
        icon: Icons.tune_outlined,
        title: store.attributeSetTotalItems == 0
            ? 'No attribute sets'
            : 'No matching attribute sets',
        message: store.attributeSetTotalItems == 0
            ? 'Create the first attribute set to manage values.'
            : 'Try a different search keyword.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: items.length + (totalPages > 1 ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return MetadataPaginationControls(
            currentPage: currentPage,
            totalPages: totalPages,
            onPrevious: currentPage > 1 ? () => onPageChange(currentPage - 1) : null,
            onNext: currentPage < totalPages ? () => onPageChange(currentPage + 1) : null,
          );
        }
        final item = items[index];
        return MetadataListCard(
          title: item.name,
          leading: const Icon(Icons.label_outline),
          detailLines: <String>[
            if (item.description?.trim().isNotEmpty == true)
              item.description!.replaceAll(RegExp(r'\s+'), ' ').trim(),
            '${item.values.length} values',
          ],
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit(item);
              if (value == 'delete') onDelete(item);
            },
            itemBuilder: (_) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
              PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
            ],
          ),
          onTap: () => onTap(item),
        );
      },
    );
  }
}
