import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/units/unit_tile.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';

class UnitList extends StatelessWidget {
  const UnitList({
    super.key,
    required this.store,
    required this.queryState,
    required this.onQueryChanged,
    required this.onReload,
    required this.onDelete,
  });

  final ProductMetadataStore store;
  final MetadataListQuery queryState;
  final ValueChanged<MetadataListQuery> onQueryChanged;
  final Future<void> Function() onReload;
  final Future<void> Function(Unit) onDelete;

  @override
  Widget build(BuildContext context) {
    final units = store.units.toList(growable: false);
    if (units.isEmpty) {
      return MetadataEmptyState(
        icon: Icons.straighten_outlined,
        title: store.unitTotalItems == 0 ? 'No units yet' : 'No matching units',
        message: store.unitTotalItems == 0
            ? 'Add your first unit to keep product data consistent.'
            : 'Try a different search keyword.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: units.length + (store.unitTotalPages > 1 ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= units.length) {
          return MetadataPaginationControls(
            currentPage: store.unitCurrentPage,
            totalPages: store.unitTotalPages,
            onPrevious: store.unitCurrentPage > 1
                ? () => _changePage(store.unitCurrentPage - 1)
                : null,
            onNext: store.unitCurrentPage < store.unitTotalPages
                ? () => _changePage(store.unitCurrentPage + 1)
                : null,
          );
        }
        return UnitTile(
          unit: units[index],
          onDeleted: onReload,
          onDelete: onDelete,
          store: store,
        );
      },
    );
  }

  void _changePage(int page) {
    onQueryChanged(queryState.copyWith(page: page));
    onReload();
  }
}
