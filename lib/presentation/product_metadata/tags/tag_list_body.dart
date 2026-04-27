import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag_extensions.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';

class TagListBody extends StatelessWidget {
  const TagListBody({
    super.key,
    required this.store,
    required this.queryState,
    required this.onPageChange,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  final ProductMetadataStore store;
  final MetadataListQuery queryState;
  final void Function(int page) onPageChange;
  final void Function(Tag tag) onEdit;
  final void Function(Tag tag) onDelete;
  final void Function(Tag tag) onTap;

  @override
  Widget build(BuildContext context) {
    final tags = store.tags.toList(growable: false);
    final totalPages = store.tagTotalPages;
    final currentPage = store.tagCurrentPage;

    if (tags.isEmpty) {
      return MetadataEmptyState(
        icon: Icons.sell_outlined,
        title: store.tagTotalItems == 0 ? 'No tags yet' : 'No matching tags',
        message: store.tagTotalItems == 0
            ? 'Add your first tag to classify products faster.'
            : 'Try a different search keyword.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: tags.length + (totalPages > 1 ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= tags.length) {
          return MetadataPaginationControls(
            currentPage: currentPage,
            totalPages: totalPages,
            onPrevious: currentPage > 1 ? () => onPageChange(currentPage - 1) : null,
            onNext: currentPage < totalPages ? () => onPageChange(currentPage + 1) : null,
          );
        }
        final tag = tags[index];
        return MetadataListCard(
          title: tag.name,
          leading: const Icon(Icons.sell_outlined),
          detailLines: [
            if (tag.descriptionOrNull != null)
              tag.description!.replaceAll(RegExp(r'\s+'), ' ').trim(),
          ],
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit(tag);
              if (value == 'delete') onDelete(tag);
            },
            itemBuilder: (_) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
              PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
            ],
          ),
          onTap: () => onTap(tag),
        );
      },
    );
  }
}
