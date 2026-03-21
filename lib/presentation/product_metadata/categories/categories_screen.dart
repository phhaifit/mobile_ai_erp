import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_secondary_details.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

enum _CategorySortOption {
  sortOrder('Sort order'),
  nameAsc('Name A-Z'),
  nameDesc('Name Z-A');

  const _CategorySortOption(this.label);

  final String label;
}

class ProductMetadataCategoriesScreen extends StatefulWidget {
  const ProductMetadataCategoriesScreen({
    super.key,
    this.args,
  });

  final CategoriesArgs? args;

  @override
  State<ProductMetadataCategoriesScreen> createState() =>
      _ProductMetadataCategoriesScreenState();
}

class _ProductMetadataCategoriesScreenState
    extends State<ProductMetadataCategoriesScreen> {
  static const int _pageSize = 2;

  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  CategoryStatus? _statusFilter;
  _CategorySortOption _sortOption = _CategorySortOption.sortOrder;
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
    final parentId = widget.args?.parentCategoryId;

    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (context) => Text(_appBarTitle()),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _goToProductMetadataHome,
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Back to Product Metadata',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ProductMetadataNavigator.openCategoryForm(
            context,
            args: CategoryFormArgs(initialParentId: parentId),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(parentId == null ? 'Add category' : 'Add subcategory'),
      ),
      body: Observer(
        builder: (context) {
          final categories = _applyFilters(_store.childrenOf(parentId));
          final totalPages = _totalPages(categories.length);
          final currentPage =
              totalPages == 0 ? 1 : _currentPage.clamp(1, totalPages);
          final visibleCategories =
              _pageItems(categories, currentPage, _pageSize);

          if (_store.isLoading && !_store.hasLoadedDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: <Widget>[
              _CategoriesLevelHeader(
                currentCategory: _store.findCategoryById(parentId),
                path: _buildPath(parentId),
                onNavigateToLevel: (String? nextParentId) {
                  if (nextParentId == parentId) {
                    return;
                  }
                  ProductMetadataNavigator.openCategories(
                    context,
                    args: CategoriesArgs(parentCategoryId: nextParentId),
                  );
                },
              ),
              const SizedBox(height: 16),
              MetadataListControls(
                searchController: _searchController,
                onSearchChanged: (value) => setState(() {
                  _query = value.trim();
                  _currentPage = 1;
                }),
                searchHint: 'Search by name, code, or slug',
                resultLabel:
                    'Showing ${visibleCategories.length} of ${categories.length} categories',
                hasActiveFilter: _statusFilter != null,
                hasCustomSort: _sortOption != _CategorySortOption.sortOrder,
                onOpenFilter: _openFilterSheet,
                onOpenSort: _openSortSheet,
              ),
              const SizedBox(height: 16),
              if (categories.isEmpty)
                _CategoriesEmptyState(
                  currentCategory: _store.findCategoryById(parentId),
                  hasFilters: _query.isNotEmpty || _statusFilter != null,
                )
              else ...<Widget>[
                ...visibleCategories
                    .map((category) => _buildCategoryRow(category)),
                if (totalPages > 1)
                  MetadataPaginationControls(
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
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Category> _applyFilters(List<Category> source) {
    final query = _query.toLowerCase();
    final filtered = source.where((category) {
      if (_statusFilter != null && category.status != _statusFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return category.name.toLowerCase().contains(query) ||
          category.code.toLowerCase().contains(query) ||
          category.slug.toLowerCase().contains(query);
    }).toList();

    filtered.sort((left, right) {
      switch (_sortOption) {
        case _CategorySortOption.sortOrder:
          final orderCompare = left.sortOrder.compareTo(right.sortOrder);
          if (orderCompare != 0) {
            return orderCompare;
          }
          return left.name.toLowerCase().compareTo(right.name.toLowerCase());
        case _CategorySortOption.nameAsc:
          return left.name.toLowerCase().compareTo(right.name.toLowerCase());
        case _CategorySortOption.nameDesc:
          return right.name.toLowerCase().compareTo(left.name.toLowerCase());
      }
    });

    return filtered;
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<CategoryStatus?>(
      context: context,
      builder: (context) {
        CategoryStatus? tempStatus = _statusFilter;
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
                      'Filter categories',
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
                    for (final status in CategoryStatus.values)
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
    final selected = await showModalBottomSheet<_CategorySortOption>(
      context: context,
      builder: (context) {
        _CategorySortOption tempSort = _sortOption;
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
                      'Sort categories',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    for (final option in _CategorySortOption.values)
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

  List<Category> _pageItems(List<Category> items, int page, int pageSize) {
    final start = (page - 1) * pageSize;
    if (start >= items.length) {
      return const <Category>[];
    }
    final end = (start + pageSize).clamp(0, items.length);
    return items.sublist(start, end);
  }

  String _appBarTitle() {
    final parentCategory =
        _store.findCategoryById(widget.args?.parentCategoryId);
    return parentCategory?.name ?? 'Categories';
  }

  void _goToProductMetadataHome() {
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name ==
              ProductMetadataNavigator.productMetadataHomeRoute ||
          route.isFirst,
    );
  }

  List<Category> _buildPath(String? categoryId) {
    final path = <Category>[];
    var current = _store.findCategoryById(categoryId);

    while (current != null) {
      path.insert(0, current);
      current = _store.findCategoryById(current.parentId);
    }

    return path;
  }

  Widget _buildCategoryRow(Category category) {
    final children = _store.childrenOf(category.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ProductMetadataNavigator.openCategoryDetail(
              context,
              args: CategoryDetailArgs(categoryId: category.id),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      children.isEmpty
                          ? Icons.folder_outlined
                          : Icons.account_tree_outlined,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (children.isNotEmpty) ...<Widget>[
                      _SubcategoryCountBadge(count: children.length),
                      const SizedBox(width: 8),
                    ],
                    if (children.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          ProductMetadataNavigator.openCategories(
                            context,
                            args: CategoriesArgs(parentCategoryId: category.id),
                          );
                        },
                        icon: const Icon(Icons.chevron_right),
                        tooltip: 'View subcategories',
                        visualDensity: VisualDensity.compact,
                      ),
                    const SizedBox(width: 4),
                    _CategoryActionsMenu(
                      onSelected: (_CategoryMenuAction action) {
                        switch (action) {
                          case _CategoryMenuAction.addChild:
                            ProductMetadataNavigator.openCategoryForm(
                              context,
                              args: CategoryFormArgs(
                                initialParentId: category.id,
                              ),
                            );
                            return;
                          case _CategoryMenuAction.edit:
                            ProductMetadataNavigator.openCategoryForm(
                              context,
                              args: CategoryFormArgs(categoryId: category.id),
                            );
                            return;
                          case _CategoryMenuAction.delete:
                            _deleteCategory(category);
                            return;
                        }
                      },
                    ),
                  ],
                ),
                if (_categorySummary(category).isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const SizedBox(width: 36),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            MetadataSecondaryDetails(
                              lines: _categorySummary(category),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                MetadataStatusChip(
                                    label: category.status.label),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _categorySummary(Category category) {
    return <String>[
      'Code: ${category.code}',
      'Slug: ${category.slug}',
      'Sort order: ${category.sortOrder}',
    ];
  }

  Future<void> _deleteCategory(Category category) async {
    final hasChildren = _store.childrenOf(category.id).isNotEmpty;
    if (hasChildren) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Can\'t delete category'),
            content: Text(
              'Remove or move the child categories under "${category.name}" first.',
            ),
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          );
        },
      );
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete category?'),
              content:
                  Text('Delete "${category.name}"? This can\'t be undone.'),
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
      await _store.deleteCategory(category.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${category.name}".')),
      );
    } catch (error) {
      debugPrint('Failed to delete category: $error');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn\'t delete category. Try again.'),
        ),
      );
    }
  }
}

enum _CategoryMenuAction { addChild, edit, delete }

class _CategoryActionsMenu extends StatelessWidget {
  const _CategoryActionsMenu({required this.onSelected});

  final ValueChanged<_CategoryMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CategoryMenuAction>(
      tooltip: 'Category actions',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      iconSize: 20,
      onSelected: onSelected,
      itemBuilder: (context) => const <PopupMenuEntry<_CategoryMenuAction>>[
        PopupMenuItem<_CategoryMenuAction>(
          value: _CategoryMenuAction.addChild,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.add_circle_outline),
            title: Text('Add subcategory'),
          ),
        ),
        PopupMenuItem<_CategoryMenuAction>(
          value: _CategoryMenuAction.edit,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
          ),
        ),
        PopupMenuItem<_CategoryMenuAction>(
          value: _CategoryMenuAction.delete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline),
            title: Text('Delete'),
          ),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }
}

class _SubcategoryCountBadge extends StatelessWidget {
  const _SubcategoryCountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 40, minHeight: 28),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '($count)',
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CategoriesLevelHeader extends StatelessWidget {
  const _CategoriesLevelHeader({
    required this.currentCategory,
    required this.path,
    required this.onNavigateToLevel,
  });

  final Category? currentCategory;
  final List<Category> path;
  final ValueChanged<String?> onNavigateToLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (path.isEmpty)
          const SizedBox.shrink()
        else ...<Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onNavigateToLevel(null),
                  child: const Text('Root'),
                ),
                for (final category in path) ...<Widget>[
                  const Icon(Icons.chevron_right, size: 20),
                  TextButton(
                    onPressed: () => onNavigateToLevel(category.id),
                    child: Text(category.name),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoriesEmptyState extends StatelessWidget {
  const _CategoriesEmptyState({
    required this.currentCategory,
    required this.hasFilters,
  });

  final Category? currentCategory;
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return MetadataEmptyState(
      icon: currentCategory == null
          ? Icons.account_tree_outlined
          : Icons.folder_open_outlined,
      title: hasFilters
          ? 'No matching categories'
          : currentCategory == null
              ? 'No categories yet'
              : 'No subcategories yet',
      message: hasFilters
          ? 'Try changing your search, filter, or sort order.'
          : currentCategory == null
              ? 'Add the first category to organize product metadata.'
              : 'Add a subcategory to continue organizing this level.',
    );
  }
}
