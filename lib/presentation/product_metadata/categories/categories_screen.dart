import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/logic/metadata_pagination_logic.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/models/metadata_list_query.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_route_args.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_empty_state.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/utils/metadata_error_formatter.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_list_layout.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/widgets/metadata_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/categories_level_header.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_list_item.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/categories/widgets/category_tree_item.dart';

class ProductMetadataCategoriesScreen extends StatefulWidget {
  const ProductMetadataCategoriesScreen({super.key, this.args});

  final CategoriesArgs? args;

  @override
  State<ProductMetadataCategoriesScreen> createState() =>
      _ProductMetadataCategoriesScreenState();
}

class _ProductMetadataCategoriesScreenState
    extends State<ProductMetadataCategoriesScreen>
    with SingleTickerProviderStateMixin {
  final ProductMetadataStore _store = getIt<ProductMetadataStore>();
  final TextEditingController _searchController = TextEditingController();
  MetadataListQuery _queryState = const MetadataListQuery();
  late TabController _tabController;
  Timer? _searchDebounce;
  late List<ReactionDisposer> _disposers;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.args?.initialTabIndex ??
        (widget.args?.parentCategoryId == null ? 0 : 1);
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(_handleTabSelection);
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
                    actionLabel: 'load categories',
                  ),
                ),
              ),
            );
          }
        },
      ),
    ];
    Future<void>.microtask(() async {
      await Future.wait([
        _loadCategories(),
        _store.loadCategoryTree(),
      ]);
    });
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final d in _disposers) {
      d();
    }
    _searchDebounce?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parentId = widget.args?.parentCategoryId;

    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (context) {
            final _ = _store.isLoading;
            return Text(_appBarTitle());
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'List'),
            Tab(text: 'Tree'),
          ],
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
          final isTreeTab = _tabController.index == 1;
          final currentParentId = isTreeTab ? parentId : null;
          ProductMetadataNavigator.openCategoryForm(
            context,
            args: CategoryFormArgs(initialParentId: currentParentId),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(
          _tabController.index == 1 && parentId != null
              ? 'Add subcategory'
              : 'Add category',
        ),
      ),
      body: Observer(
        builder: (context) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildListTab(context),
              _buildTreeTab(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListTab(BuildContext context) {
    final items = _store.categories.toList(growable: false);
    final totalPages = _store.categoryTotalPages;
    final currentPage = _store.categoryCurrentPage;

    return MetadataListLayout(
      isLoading: _store.isLoading,
      controls: MetadataListControls(
        searchController: _searchController,
        onSearchChanged: (value) {
          final trimmed = value.trim();
          _setQueryState(
            _queryState.copyWith(search: trimmed, page: 1),
          );
          _searchDebounce?.cancel();
          if (trimmed.isEmpty) {
            _loadCategories();
          } else {
            _searchDebounce = Timer(
              const Duration(milliseconds: 300),
              () => _loadCategories(),
            );
          }
        },
        searchHint: 'Search by category name',
        resultLabel:
            'Showing ${items.length} of ${_store.categoryTotalItems} categories',
        hasActiveFilter: false,
        hasCustomSort: _queryState.hasCustomSort,
        onOpenSort: _openSortSheet,
      ),
      child: items.isEmpty
          ? MetadataEmptyState(
              icon: Icons.account_tree_outlined,
              title: _queryState.search.isNotEmpty
                  ? 'No matching categories'
                  : 'No categories yet',
              message: _queryState.search.isNotEmpty
                  ? 'Try a different search keyword.'
                  : 'Add the first category to organize product metadata.',
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
                        ? () {
                            _setQueryState(
                              _queryState.copyWith(
                                page: currentPage - 1,
                              ),
                            );
                            _loadCategories();
                          }
                        : null,
                    onNext: currentPage < totalPages
                        ? () {
                            _setQueryState(
                              _queryState.copyWith(
                                page: currentPage + 1,
                              ),
                            );
                            _loadCategories();
                          }
                        : null,
                  );
                }
                final item = items[index];
                return KeyedSubtree(
                  key: ValueKey<String>(item.id),
                  child: CategoryListItem(
                    category: item,
                    onDelete: () => _deleteCategory(item),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTreeTab(BuildContext context) {
    final parentId = widget.args?.parentCategoryId;
    final categories =
        _store.categoryTree.where((cat) => cat.parentId == parentId).toList();

    return MetadataListLayout(
      isLoading: _store.isLoading,
      controls: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: CategoriesLevelHeader(
          path: _buildPath(parentId),
          onNavigateToLevel: (String? nextParentId) {
            if (nextParentId == parentId) {
              return;
            }
            ProductMetadataNavigator.openCategories(
              context,
              args: CategoriesArgs(
                parentCategoryId: nextParentId,
                initialTabIndex: 1,
              ),
            );
          },
        ),
      ),
      child: categories.isEmpty
          ? MetadataEmptyState(
              icon: _findCategory(parentId) == null
                  ? Icons.account_tree_outlined
                  : Icons.folder_open_outlined,
              title: _findCategory(parentId) == null
                  ? 'No categories yet'
                  : 'No subcategories yet',
              message: _findCategory(parentId) == null
                  ? 'Add the first category to organize product metadata.'
                  : 'Add a subcategory to continue organizing this level.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                final children = _store.categoryTree
                    .where((cat) => cat.parentId == category.id)
                    .toList();
                return KeyedSubtree(
                  key: ValueKey<String>(category.id),
                  child: CategoryTreeItem(
                    category: category,
                    hasChildren: children.isNotEmpty,
                    childrenCount: children.length,
                    onDelete: () => _deleteCategory(category),
                    onReload: _loadCategories,
                  ),
                );
              },
            ),
    );
  }

  void _setQueryState(MetadataListQuery next) {
    if (!mounted) {
      return;
    }
    setState(() {
      _queryState = next;
    });
  }

  Future<void> _loadCategories() {
    return _store.loadCategories(
      page: _queryState.page,
      pageSize: _queryState.pageSize,
      search: _queryState.search,
      sortBy: _queryState.sortBy,
      sortOrder: _queryState.sortOrder,
    );
  }

  String _appBarTitle() {
    if (_tabController.index == 0) return 'Categories';
    final parentCategory = _findCategory(widget.args?.parentCategoryId);
    return parentCategory?.name ?? 'Categories Tree';
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
    var current = _findCategory(categoryId);

    while (current != null) {
      path.insert(0, current);
      current = _findCategory(current.parentId);
    }

    return path;
  }


  Future<void> _deleteCategory(Category category) async {
    final hasChildren = _store.categoryTree
        .where((cat) => cat.parentId == category.id)
        .isNotEmpty;
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

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete category?'),
              content: Text(
                'Delete "${category.name}"? This can\'t be undone.',
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

    final previousTotalItems = _store.categoryTotalItems;
    await _store.deleteCategory(category.id);
    
    _queryState = _queryState.copyWith(
      page: resolveMetadataPageAfterDelete(
        currentPage: _queryState.page,
        pageSize: _queryState.pageSize,
        totalItems: previousTotalItems,
      ),
    );
    
    await Future.wait([
      _loadCategories(),
      _store.loadCategoryTree(),
    ]);
    
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Deleted "${category.name}".')));
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
                  'Sort categories',
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
                    _loadCategories();
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Category? _findCategory(String? categoryId) {
    final tree = _store.categoryTree;

    if (categoryId == null || categoryId.isEmpty) {
      return null;
    }

    for (final category in tree) {
      if (category.id == categoryId) {
        return category;
      }
    }

    return null;
  }
}

