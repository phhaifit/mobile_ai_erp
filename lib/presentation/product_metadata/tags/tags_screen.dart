import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_card.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

enum _TagSortOption {
  sortOrder('Sort order'),
  nameAsc('Name A-Z'),
  nameDesc('Name Z-A');

  const _TagSortOption(this.label);

  final String label;
}

class ProductMetadataTagsScreen extends StatefulWidget {
  const ProductMetadataTagsScreen({super.key});

  @override
  State<ProductMetadataTagsScreen> createState() =>
      _ProductMetadataTagsScreenState();
}

class _ProductMetadataTagsScreenState extends State<ProductMetadataTagsScreen> {
  static const int _pageSize = 10;

  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  TagStatus? _statusFilter;
  _TagSortOption _sortOption = _TagSortOption.sortOrder;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => _store.loadDashboard());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ProductMetadataNavigator.openTagForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add tag'),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && !_store.hasLoadedDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredTags = _applyFilters(_store.tags.toList());
          final totalPages = _totalPages(filteredTags.length);
          final currentPage =
              totalPages == 0 ? 1 : _currentPage.clamp(1, totalPages);
          final visibleTags = _pageItems(filteredTags, currentPage, _pageSize);

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: MetadataListControls(
                  searchController: _searchController,
                  onSearchChanged: (value) => setState(() {
                    _query = value.trim();
                    _currentPage = 1;
                  }),
                  searchHint: 'Search by tag, color, or description',
                  resultLabel:
                      'Showing ${visibleTags.length} of ${filteredTags.length} tags',
                  filterSummary: _filterSummary(),
                  hasActiveFilter: _statusFilter != null,
                  hasCustomSort: _sortOption != _TagSortOption.sortOrder,
                  onOpenFilter: _openFilterSheet,
                  onOpenSort: _openSortSheet,
                ),
              ),
              Expanded(
                child: filteredTags.isEmpty
                    ? MetadataEmptyState(
                        icon: Icons.sell_outlined,
                        title: _store.tags.isEmpty
                            ? 'No tags yet'
                            : 'No matching tags',
                        message: _store.tags.isEmpty
                            ? 'Add your first tag to classify products faster.'
                            : 'Try changing your search, filter, or sort settings.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount:
                            visibleTags.length + (totalPages > 1 ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index >= visibleTags.length) {
                            return MetadataPaginationControls(
                              currentPage: currentPage,
                              totalPages: totalPages,
                              onPrevious: currentPage > 1
                                  ? () => setState(() {
                                        _currentPage = currentPage - 1;
                                      })
                                  : null,
                              onNext: currentPage < totalPages
                                  ? () => setState(() {
                                        _currentPage = currentPage + 1;
                                      })
                                  : null,
                            );
                          }

                          final tag = visibleTags[index];
                          return MetadataListCard(
                            title: tag.name,
                            leading: _TagColorDot(colorHex: tag.colorHex),
                            detailLines: _tagSummary(tag),
                            chips: <Widget>[
                              MetadataStatusChip(label: tag.status.label),
                            ],
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    ProductMetadataNavigator.openTagForm(
                                      context,
                                      args: TagFormArgs(tagId: tag.id),
                                    );
                                    break;
                                  case 'delete':
                                    _deleteTag(tag);
                                    break;
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
                            onTap: () => ProductMetadataNavigator.openTagDetail(
                              context,
                              args: TagDetailArgs(tagId: tag.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Tag> _applyFilters(List<Tag> tags) {
    final query = _query.toLowerCase();
    final filtered = tags.where((tag) {
      if (_statusFilter != null && tag.status != _statusFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return tag.name.toLowerCase().contains(query) ||
          (tag.description?.toLowerCase().contains(query) ?? false) ||
          (tag.colorHex?.toLowerCase().contains(query) ?? false);
    }).toList();

    filtered.sort((left, right) {
      switch (_sortOption) {
        case _TagSortOption.sortOrder:
          final orderCompare = left.sortOrder.compareTo(right.sortOrder);
          if (orderCompare != 0) {
            return orderCompare;
          }
          return left.name.toLowerCase().compareTo(right.name.toLowerCase());
        case _TagSortOption.nameAsc:
          return left.name.toLowerCase().compareTo(right.name.toLowerCase());
        case _TagSortOption.nameDesc:
          return right.name.toLowerCase().compareTo(left.name.toLowerCase());
      }
    });

    return filtered;
  }

  String _filterSummary() {
    final parts = <String>[
      if (_statusFilter != null) 'Status: ${_statusFilter!.label}',
      if (_sortOption != _TagSortOption.sortOrder)
        'Sort order: ${_sortOption.label}',
    ];
    return parts.join('  |  ');
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<TagStatus?>(
      context: context,
      builder: (context) {
        TagStatus? tempStatus = _statusFilter;
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
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('All statuses'),
                      trailing:
                          tempStatus == null ? const Icon(Icons.check) : null,
                      onTap: () => setModalState(() {
                        tempStatus = null;
                      }),
                    ),
                    for (final status in TagStatus.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(status.label),
                        trailing: tempStatus == status
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => setModalState(() {
                          tempStatus = status;
                        }),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(tempStatus),
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

    if (!mounted) {
      return;
    }
    setState(() {
      _statusFilter = selected;
      _currentPage = 1;
    });
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<_TagSortOption>(
      context: context,
      builder: (context) {
        _TagSortOption tempSort = _sortOption;
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
                      'Sort tags',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    for (final option in _TagSortOption.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(option.label),
                        trailing:
                            tempSort == option ? const Icon(Icons.check) : null,
                        onTap: () => setModalState(() {
                          tempSort = option;
                        }),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(tempSort),
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

    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _sortOption = selected;
      _currentPage = 1;
    });
  }

  int _totalPages(int itemCount) =>
      itemCount == 0 ? 0 : ((itemCount - 1) ~/ _pageSize) + 1;

  List<Tag> _pageItems(List<Tag> items, int page, int pageSize) {
    final start = (page - 1) * pageSize;
    if (start >= items.length) {
      return const <Tag>[];
    }
    final end = (start + pageSize).clamp(0, items.length);
    return items.sublist(start, end);
  }

  List<String> _tagSummary(Tag tag) {
    return <String>[
      if (tag.description != null && tag.description!.trim().isNotEmpty)
        tag.description!.trim(),
      if (tag.colorHex != null && tag.colorHex!.trim().isNotEmpty)
        'Color: ${tag.colorHex}',
      'Sort order: ${tag.sortOrder}',
    ];
  }

  Future<void> _deleteTag(Tag tag) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete tag?'),
              content: Text('Delete "${tag.name}"? This can\'t be undone.'),
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

    try {
      await _store.deleteTag(tag.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${tag.name}".')),
      );
    } catch (error) {
      debugPrint('Failed to delete tag: $error');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t delete tag. Try again.'),
        ),
      );
    }
  }
}

class _TagColorDot extends StatelessWidget {
  const _TagColorDot({required this.colorHex});

  final String? colorHex;

  @override
  Widget build(BuildContext context) {
    final parsedColor = _parseColor(colorHex);
    if (parsedColor == null) {
      return const Icon(Icons.sell_outlined);
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: parsedColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }

  Color? _parseColor(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim().replaceFirst('#', '');
    if (normalized.length != 6) {
      return null;
    }
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) {
      return null;
    }
    return Color(0xFF000000 | parsed);
  }
}
