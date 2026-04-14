import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/units/unit_detail_content.dart';

class ProductMetadataUnitDetailScreen extends StatefulWidget {
  const ProductMetadataUnitDetailScreen({super.key, required this.args});

  final UnitDetailArgs args;

  @override
  State<ProductMetadataUnitDetailScreen> createState() =>
      _ProductMetadataUnitDetailScreenState();
}

class _ProductMetadataUnitDetailScreenState
    extends State<ProductMetadataUnitDetailScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  late Future<void> _loadUnitFuture;
  Unit? _unit;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUnitFuture = _loadUnit();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadUnitFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Unit detail'),
              leading: BackButton(
                onPressed: () => Navigator.of(context).pop(_hasChanged),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final unit = _unit;
        if (unit == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Unit detail'),
              leading: BackButton(
                onPressed: () => Navigator.of(context).pop(_hasChanged),
              ),
            ),
            body: const Center(child: Text('Unit not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Unit detail'),
            leading: BackButton(
              onPressed: () => Navigator.of(context).pop(_hasChanged),
            ),
            actions: <Widget>[
              IconButton(
                onPressed: () => _editUnit(unit),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit unit',
              ),
            ],
          ),
          body: UnitDetailContent(unit: unit),
        );
      },
    );
  }

  Future<void> _loadUnit() async {
    try {
      _unit = await _store.getUnitById(widget.args.unitId);
    } catch (_) {
      _unit = null;
    }
  }

  Future<void> _editUnit(Unit unit) async {
    final didChange = await ProductMetadataNavigator.openUnitForm<bool>(
      context,
      args: UnitFormArgs(unitId: unit.id),
    );
    if (didChange == true && mounted) {
      _hasChanged = true;
      // Reload the unit to get the latest state
      await _loadUnit();
      final updatedUnit = _unit;
      if (!mounted) {
        return;
      }
      // If unit was deactivated or not found, go back to units list immediately
      if (updatedUnit == null || !updatedUnit.isActive) {
        Navigator.of(context).pop(true);
        return;
      }
      // Otherwise, refresh the detail view
      setState(() {
        _loadUnitFuture = _loadUnit();
      });
    }
  }
}
