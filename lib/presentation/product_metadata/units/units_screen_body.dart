import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/units/unit_filter_sheet.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/units/unit_list.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_layout.dart';

class ProductMetadataUnitsScreenBody extends StatelessWidget {
  const ProductMetadataUnitsScreenBody({
    super.key,
    required this.store,
    required this.queryState,
    required this.searchController,
    required this.onQueryChanged,
    required this.onReload,
    required this.onDelete,
    this.onOpenSort,
  });

  final ProductMetadataStore store;
  final MetadataListQuery queryState;
  final TextEditingController searchController;
  final ValueChanged<MetadataListQuery> onQueryChanged;
  final Future<void> Function() onReload;
  final Future<void> Function(Unit) onDelete;
  final Future<void> Function()? onOpenSort;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final units = store.units.toList(growable: false);
        return MetadataListLayout(
          isLoading: store.isLoading,
          controls: MetadataListControls(
            searchController: searchController,
            onSearchChanged: (value) {
              onQueryChanged(
                queryState.copyWith(search: value.trim(), page: 1),
              );
              onReload();
            },
            searchHint: 'Search by unit name',
            resultLabel:
                'Showing ${units.length} of ${store.unitTotalItems} units',
            hasActiveFilter: queryState.includeInactive,
            hasCustomSort: queryState.hasCustomSort,
            onOpenFilter: () async {
              final next = await showUnitFilterSheet(context, queryState);
              if (next != null) {
                onQueryChanged(next);
                await onReload();
              }
            },
            onOpenSort: onOpenSort,
          ),
          child: UnitList(
            store: store,
            queryState: queryState,
            onQueryChanged: onQueryChanged,
            onReload: onReload,
            onDelete: onDelete,
          ),
        );
      },
    );
  }
}
