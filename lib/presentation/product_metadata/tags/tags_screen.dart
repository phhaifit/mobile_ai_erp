import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag_extensions.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/logic/metadata_pagination_logic.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_layout.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_inactive_snackbar.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';

class ProductMetadataTagsScreen extends StatefulWidget {
  const ProductMetadataTagsScreen({super.key});

  @override
  State<ProductMetadataTagsScreen> createState() =>
      _ProductMetadataTagsScreenState();
}

class _ProductMetadataTagsScreenState extends State<ProductMetadataTagsScreen> {
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
                    actionLabel: 'load tags',
                  ),
                ),
              ),
            );
          }
        },
      ),
    ];
    Future<void>.microtask(_loadTags);
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
        title: const Text('Tags'),
        actions: <Widget>[
          IconButton(
            onPressed: _goToProductMetadataHome,
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Back to Product Metadata',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openTagForm,
        icon: const Icon(Icons.add),
        label: const Text('Add tag'),
      ),
      body: Observer(
        builder: (context) {
          final tags = _store.tags.toList(growable: false);
          final totalPages = _store.tagTotalPages;
          final currentPage = _store.tagCurrentPage;

          return MetadataListLayout(
            isLoading: _store.isLoading,
            controls: MetadataListControls(
              searchController: _searchController,
              onSearchChanged: (value) => setState(() {
                _queryState = _queryState.copyWith(
                  search: value.trim(),
                  page: 1,
                );
                _loadTags();
              }),
              searchHint: 'Search by tag name',
              resultLabel:
                  'Showing ${tags.length} of ${_store.tagTotalItems} tags',
              hasActiveFilter: _queryState.includeInactive,
              hasCustomSort: _queryState.hasCustomSort,
              onOpenFilter: _openFilterSheet,
              onOpenSort: _openSortSheet,
            ),
            child: tags.isEmpty
                ? MetadataEmptyState(
                    icon: Icons.sell_outlined,
                    title: _store.tagTotalItems == 0
                        ? 'No tags yet'
                        : 'No matching tags',
                    message: _store.tagTotalItems == 0
                        ? 'Add your first tag to classify products faster.'
                        : 'Try a different search keyword.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: tags.length + (totalPages > 1 ? 1 : 0),
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index >= tags.length) {
                      return MetadataPaginationControls(
                        currentPage: currentPage,
                        totalPages: totalPages,
                        onPrevious: currentPage > 1
                            ? () => setState(() {
                                  _queryState = _queryState.copyWith(
                                    page: currentPage - 1,
                                  );
                                  _loadTags();
                                })
                            : null,
                        onNext: currentPage < totalPages
                            ? () => setState(() {
                                  _queryState = _queryState.copyWith(
                                    page: currentPage + 1,
                                  );
                                  _loadTags();
                                })
                            : null,
                      );
                    }

                    final tag = tags[index];
                    return MetadataListCard(
                      title: tag.name,
                      leading: const Icon(Icons.sell_outlined),
                      detailLines: _tagSummary(tag),
                      chips: <Widget>[
                        MetadataStatusChip(
                          label: tag.isActive ? 'Active' : 'Inactive',
                        ),
                      ],
                      trailing: tag.isActive
                          ? PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _openTagForm(
                                      args: TagFormArgs(tagId: tag.id),
                                    );
                                    break;
                                  case 'delete':
                                    _deleteTag(tag);
                                    break;
                                }
                              },
                              itemBuilder: (context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Deactivate'),
                                ),
                              ],
                            )
                          : null,
                      onTap: tag.isActive
                          ? () => _openTagDetail(tag)
                          : () => showMetadataInactiveSnackbar(
                                context,
                                itemType: 'tag',
                              ),
                    );
                  },
                ),
          );
        },
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final includeInactive = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        var tempValue = _queryState.includeInactive;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Filter tags',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      value: tempValue,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include inactive'),
                      onChanged: (value) => setModalState(() {
                        tempValue = value;
                      }),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(tempValue),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (includeInactive == null || !mounted) {
      return;
    }
    setState(() {
      _queryState = _queryState.copyWith(
        includeInactive: includeInactive,
        page: 1,
      );
      _loadTags();
    });
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
                  'Sort tags',
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
                    _loadTags();
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

  Future<void> _openTagForm({TagFormArgs? args}) async {
    final didChange = await ProductMetadataNavigator.openTagForm<bool>(
      context,
      args: args,
    );
    if (didChange == true && mounted) {
      await _loadTags();
    }
  }

  Future<void> _openTagDetail(Tag tag) async {
    await ProductMetadataNavigator.openTagDetail<void>(
      context,
      args: TagDetailArgs(tagId: tag.id),
    );
    if (mounted) {
      await _loadTags();
    }
  }

  List<String> _tagSummary(Tag tag) {
    return <String>[
      if (tag.descriptionOrNull != null) tag.description!.replaceAll(RegExp(r'\s+'), ' ').trim(),
    ];
  }

  Future<void> _deleteTag(Tag tag) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Deactivate tag?'),
              content: Text(
                'Deactivate "${tag.name}"? This tag will be marked as inactive.',
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

    final previousTotalItems = _store.tagTotalItems;
    await _store.deleteTag(tag.id);
    final effectiveTotalItems = _queryState.includeInactive
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
    await _loadTags();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deactivated "${tag.name}".')),
    );
  }

  Future<void> _loadTags() {
    return _store.loadTags(
      page: _queryState.page,
      pageSize: _queryState.pageSize,
      search: _queryState.search,
      includeInactive: _queryState.includeInactive,
    );
  }
}
