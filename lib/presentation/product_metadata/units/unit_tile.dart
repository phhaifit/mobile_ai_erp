import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_inactive_snackbar.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';

class UnitTile extends StatelessWidget {
  const UnitTile({
    super.key,
    required this.unit,
    required this.onDeleted,
    required this.onDelete,
    required this.store,
  });

  final Unit unit;
  final Future<void> Function() onDeleted;
  final Future<void> Function(Unit) onDelete;
  final ProductMetadataStore store;

  @override
  Widget build(BuildContext context) {
    return MetadataListCard(
      title: unit.name,
      leading: const Icon(Icons.straighten_outlined),
      detailLines: <String>[
        if (unit.symbol?.trim().isNotEmpty == true) 'Symbol: ${unit.symbol}',
        if (unit.description?.trim().isNotEmpty == true) unit.description!,
      ],
      chips: <Widget>[
        MetadataStatusChip(label: unit.isActive ? 'Active' : 'Inactive'),
      ],
      trailing: unit.isActive
          ? PopupMenuButton<String>(
              onSelected: (value) =>
                  value == 'edit' ? _edit(context) : _deleteUnit(context),
              itemBuilder: (context) => const <PopupMenuEntry<String>>[
                PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                PopupMenuItem<String>(value: 'delete', child: Text('Deactivate')),
              ],
            )
          : null,
      onTap: unit.isActive
          ? () async {
              await ProductMetadataNavigator.openUnitDetail<void>(
                context,
                args: UnitDetailArgs(unitId: unit.id),
              );
              if (context.mounted) {
                await onDeleted();
              }
            }
          : () => showMetadataInactiveSnackbar(
                context,
                itemType: 'unit',
              ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final didChange = await ProductMetadataNavigator.openUnitForm<bool>(
      context,
      args: UnitFormArgs(unitId: unit.id),
    );
    if (didChange == true) {
      await onDeleted();
    }
  }

  Future<void> _deleteUnit(BuildContext context) async {
    await onDelete(unit);
  }
}
