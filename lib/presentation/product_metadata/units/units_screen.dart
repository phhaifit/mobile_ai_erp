import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/logic/metadata_pagination_logic.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/units/units_screen_body.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';

class ProductMetadataUnitsScreen extends StatefulWidget {
  const ProductMetadataUnitsScreen({super.key});

  @override
  State<ProductMetadataUnitsScreen> createState() =>
      _ProductMetadataUnitsScreenState();
}

class _ProductMetadataUnitsScreenState
    extends State<ProductMetadataUnitsScreen> {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  MetadataListQuery _queryState = const MetadataListQuery();
  late List<ReactionDisposer> _disposers;

  @override
  void initState() {
    super.initState();
    _disposers = [
      reaction(
        (_) => _store.errorStore.errorMessage,
        (String message) {
          final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
          if (message.isNotEmpty && mounted && isCurrent) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.clearSnackBars();
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  MetadataErrorFormatter.formatActionError(
                    error: message,
                    actionLabel: 'load units',
                  ),
                ),
              ),
            );
          }
        },
      ),
    ];
    Future<void>.microtask(_loadUnits);
  }

  @override
  void dispose() {
    for (final d in _disposers) {
      d();
    }
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Units'),
        actions: <Widget>[
          IconButton(
            onPressed: _goHome,
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Back to Product Metadata',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ProductMetadataNavigator.openUnitForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add unit'),
      ),
      body: Observer(
        builder: (context) => ProductMetadataUnitsScreenBody(
          store: _store,
          queryState: _queryState,
          searchController: _searchController,
          onQueryChanged: _setQueryState,
          onReload: _loadUnits,
          onDelete: _deleteUnit,
          onOpenSort: _openSortSheet,
        ),
      ),
    );
  }

  Future<void> _loadUnits() {
    return _store.loadUnits(
      page: _queryState.page,
      pageSize: _queryState.pageSize,
      search: _queryState.search,
      includeInactive: _queryState.includeInactive,
      sortBy: _queryState.sortBy,
      sortOrder: _queryState.sortOrder,
    );
  }

  Future<void> _openSortSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sort units',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                RadioListTile<String>(
                  value: 'name_asc',
                  groupValue: 'name_asc',
                  activeColor: Theme.of(context).colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Name (A-Z)'),
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _setQueryState(
                      _queryState.copyWith(
                        sortBy: 'name',
                        sortOrder: 'asc',
                        page: 1,
                      ),
                    );
                    _loadUnits();
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setQueryState(MetadataListQuery next) {
    setState(() => _queryState = next);
  }

  void _goHome() {
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name ==
              ProductMetadataNavigator.productMetadataHomeRoute ||
          route.isFirst,
    );
  }

  Future<void> _deleteUnit(Unit unit) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Deactivate unit?'),
              content: Text(
                'Deactivate "${unit.name}"? This unit will be marked as inactive.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Deactivate'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      final previousTotalItems = _store.unitTotalItems;
      await _store.deleteUnit(unit.id);
      final effectiveTotalItems =
          _queryState.includeInactive
              ? previousTotalItems
              : (previousTotalItems > 0 ? previousTotalItems - 1 : 0);
      _queryState = _queryState.copyWith(
        page: resolveMetadataPageAfterDelete(
          currentPage: _queryState.page,
          pageSize: _queryState.pageSize,
          totalItems: effectiveTotalItems,
          includeInactive: _queryState.includeInactive,
        ),
      );
      await _loadUnits();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deactivated "${unit.name}".'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MetadataErrorFormatter.formatActionError(
              error: error,
              actionLabel: 'deactivate unit',
            ),
          ),
        ),
      );
    }
  }

}
