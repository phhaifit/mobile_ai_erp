import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_extensions.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/brand_logo_avatar.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';

class BrandListBody extends StatelessWidget {
  const BrandListBody({
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
  final void Function(Brand brand) onEdit;
  final void Function(Brand brand) onDelete;
  final void Function(Brand brand) onTap;

  @override
  Widget build(BuildContext context) {
    final brands = store.brands.toList(growable: false);
    final totalPages = store.brandTotalPages;
    final currentPage = store.brandCurrentPage;
    final hasActiveQuery = queryState.search.isNotEmpty;

    if (brands.isEmpty) {
      return MetadataEmptyState(
        icon: Icons.workspace_premium_outlined,
        title: hasActiveQuery ? 'No matching brands' : 'No brands yet',
        message: hasActiveQuery
            ? 'Try a different search keyword.'
            : 'Add your first brand to keep product data consistent.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: brands.length + (totalPages > 1 ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= brands.length) {
          return MetadataPaginationControls(
            currentPage: currentPage,
            totalPages: totalPages,
            onPrevious: currentPage > 1 ? () => onPageChange(currentPage - 1) : null,
            onNext: currentPage < totalPages ? () => onPageChange(currentPage + 1) : null,
          );
        }
        final brand = brands[index];
        return MetadataListCard(
          title: brand.name,
          leading: BrandLogoAvatar(name: brand.name, logoUrl: brand.logoUrl),
          detailLines: [
            if (brand.descriptionOrNull != null)
              brand.description!.replaceAll(RegExp(r'\s+'), ' ').trim(),
          ],
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit(brand);
              if (value == 'delete') onDelete(brand);
            },
            itemBuilder: (_) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
              PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
            ],
          ),
          onTap: () => onTap(brand),
        );
      },
    );
  }
}
