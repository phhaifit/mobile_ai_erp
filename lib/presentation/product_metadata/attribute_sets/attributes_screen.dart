import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/logic/metadata_pagination_logic.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_layout.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';

class ProductMetadataAttributesScreen extends StatefulWidget {
  const ProductMetadataAttributesScreen({
    super.key,
    this.args = const AttributesArgs(),
  });

  final AttributesArgs args;

  @override
  State<ProductMetadataAttributesScreen> createState() =>
      _ProductMetadataAttributesScreenState();
}

class _ProductMetadataAttributesScreenState
    extends State<ProductMetadataAttributesScreen> {
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
                    actionLabel: 'load attribute sets',
                  ),
                ),
              ),
            );
          }
        },
      ),
    ];
    Future<void>.microtask(_loadAttributeSets);
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
        title: const Text('Attribute sets'),
        actions: <Widget>[
          IconButton(
            onPressed: _goToProductMetadataHome,
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Back to Product Metadata',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final changed = await ProductMetadataNavigator.openAttributeForm(context);
          if (changed == true) _loadAttributeSets();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add attribute set'),
      ),
      body: Observer(
        builder: (context) {
          final items = _store.attributeSets.toList(growable: false);
          final totalPages = _store.attributeSetTotalPages;
          final currentPage = _store.attributeSetCurrentPage;

          return MetadataListLayout(
            isLoading: _store.isLoading,
            controls: MetadataListControls(
              searchController: _searchController,
              onSearchChanged: (value) => setState(() {
                _queryState = _queryState.copyWith(
                  search: value.trim(),
                  page: 1,
                );
                _loadAttributeSets();
              }),
              searchHint: 'Search by attribute set name',
              resultLabel:
                  'Showing ${items.length} of ${_store.attributeSetTotalItems} attribute sets',
              hasCustomSort: _queryState.hasCustomSort,
              onOpenSort: _openSortSheet,
            ),
            child: items.isEmpty
                ? MetadataEmptyState(
                    icon: Icons.tune_outlined,
                    title: _store.attributeSetTotalItems == 0
                        ? 'No attribute sets'
                        : 'No matching attribute sets',
                    message: _store.attributeSetTotalItems == 0
                        ? 'Create the first attribute set to manage values.'
                        : 'Try a different search keyword.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: items.length + (totalPages > 1 ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index >= items.length) {
                        return MetadataPaginationControls(
                          currentPage: currentPage,
                          totalPages: totalPages,
                          onPrevious: currentPage > 1
                              ? () => setState(() {
                                    _queryState = _queryState.copyWith(
                                      page: currentPage - 1,
                                    );
                                    _loadAttributeSets();
                                  })
                              : null,
                          onNext: currentPage < totalPages
                              ? () => setState(() {
                                    _queryState = _queryState.copyWith(
                                      page: currentPage + 1,
                                    );
                                    _loadAttributeSets();
                                  })
                              : null,
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
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final changed = await ProductMetadataNavigator.openAttributeForm(
                                context,
                                args: AttributeFormArgs(attributeId: item.id),
                              );
                              if (changed == true) _loadAttributeSets();
                              return;
                            }
                            if (value == 'delete') {
                              _deleteAttributeSet(item);
                            }
                          },
                          itemBuilder: (context) =>
                              const <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                        onTap: () async {
                          await ProductMetadataNavigator.openAttributeDetail(
                            context,
                            args: AttributeDetailArgs(attributeId: item.id),
                          );
                          if (mounted) {
                            await _loadAttributeSets();
                          }
                        },
                      );
                    },
                  ),
          );
        },
      ),
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
                  'Sort attribute sets',
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
                    setState(() {
                      _queryState = _queryState.copyWith(
                        sortBy: 'name',
                        sortOrder: 'asc',
                        page: 1,
                      );
                    });
                    _loadAttributeSets();
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

  void _goToProductMetadataHome() {
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name ==
              ProductMetadataNavigator.productMetadataHomeRoute ||
          route.isFirst,
    );
  }

  Future<void> _deleteAttributeSet(AttributeSet item) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete attribute set?'),
              content: Text(
                'Delete "${item.name}"? This will also delete all its associated values. This action cannot be undone.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    final previousTotalItems = _store.attributeSetTotalItems;
    await _store.deleteAttributeSet(item.id);
    
    _queryState = _queryState.copyWith(
      page: resolveMetadataPageAfterDelete(
        currentPage: _queryState.page,
        pageSize: _queryState.pageSize,
        totalItems: previousTotalItems,
      ),
    );
    
    await _loadAttributeSets();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted attribute set "${item.name}".'),
      ),
    );
  }

  Future<void> _loadAttributeSets() {
    return _store.loadAttributeSets(
      page: _queryState.page,
      pageSize: _queryState.pageSize,
      search: _queryState.search,
      sortBy: _queryState.sortBy,
      sortOrder: _queryState.sortOrder,
    );
  }
}

