import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_navigator.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_route_args.dart';
import 'package:mobile_ai_erp/presentation/customer_management/store/customer_store.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_empty_state.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_list_controls.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

enum _GroupSortOption {
  sortOrder('Sort order'),
  nameAsc('Name A-Z'),
  nameDesc('Name Z-A');

  const _GroupSortOption(this.label);

  final String label;
}

class _GroupFilterResult {
  const _GroupFilterResult({this.status});

  final CustomerGroupStatus? status;
}

class CustomerGroupsScreen extends StatefulWidget {
  const CustomerGroupsScreen({super.key});

  @override
  State<CustomerGroupsScreen> createState() => _CustomerGroupsScreenState();
}

class _CustomerGroupsScreenState extends State<CustomerGroupsScreen> {
  static const int _pageSize = 10;

  final CustomerStore _store = getIt<CustomerStore>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  CustomerGroupStatus? _statusFilter;
  _GroupSortOption _sortOption = _GroupSortOption.sortOrder;
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
        title: const Text('Customer Groups'),
        actions: <Widget>[
          IconButton(
            onPressed: _goToHome,
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Back to Customer Management',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CustomerNavigator.openGroupForm(context),
        icon: const Icon(Icons.group_add_outlined),
        label: const Text('Add group'),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && !_store.hasLoadedDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = _applyFilters(_store.groups.toList());
          final totalPages = _totalPages(filtered.length);
          final currentPage =
              totalPages == 0 ? 1 : _currentPage.clamp(1, totalPages);
          final visible = _pageItems(filtered, currentPage, _pageSize);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: <Widget>[
              CustomerListControls(
                searchController: _searchController,
                onSearchChanged: (value) => setState(() {
                  _query = value.trim();
                  _currentPage = 1;
                }),
                searchHint: 'Search by group name',
                resultLabel:
                    'Showing ${visible.length} of ${filtered.length} groups',
                hasActiveFilter: _statusFilter != null,
                hasCustomSort:
                    _sortOption != _GroupSortOption.sortOrder,
                onOpenFilter: _openFilterSheet,
                onOpenSort: _openSortSheet,
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                CustomerEmptyState(
                  icon: Icons.group_work_outlined,
                  title: _query.isNotEmpty || _statusFilter != null
                      ? 'No matching groups'
                      : 'No groups yet',
                  message: _query.isNotEmpty || _statusFilter != null
                      ? 'Try changing your search or filter.'
                      : 'Add the first customer group to start segmenting.',
                )
              else ...<Widget>[
                ...visible.map(_buildGroupCard),
                if (totalPages > 1)
                  CustomerPaginationControls(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPrevious: currentPage > 1
                        ? () =>
                            setState(() => _currentPage = currentPage - 1)
                        : null,
                    onNext: currentPage < totalPages
                        ? () =>
                            setState(() => _currentPage = currentPage + 1)
                        : null,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<CustomerGroup> _applyFilters(List<CustomerGroup> source) {
    final query = _query.toLowerCase();
    final filtered = source.where((g) {
      if (_statusFilter != null && g.status != _statusFilter) return false;
      if (query.isEmpty) return true;
      return g.name.toLowerCase().contains(query) ||
          (g.description?.toLowerCase().contains(query) ?? false);
    }).toList();

    filtered.sort((a, b) {
      switch (_sortOption) {
        case _GroupSortOption.sortOrder:
          final orderCompare = a.sortOrder.compareTo(b.sortOrder);
          if (orderCompare != 0) return orderCompare;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _GroupSortOption.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _GroupSortOption.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      }
    });

    return filtered;
  }

  Widget _buildGroupCard(CustomerGroup group) {
    final count = _store.customerCountForGroup(group.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => CustomerNavigator.openGroupForm(
            context,
            args: CustomerGroupFormArgs(groupId: group.id),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: <Widget>[
                _GroupColorDot(colorHex: group.colorHex),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (group.description != null &&
                          group.description!.trim().isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          group.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          CustomerStatusChip(label: group.status.label),
                          CustomerStatusChip(
                              label: '$count customer${count != 1 ? 's' : ''}'),
                        ],
                      ),
                    ],
                  ),
                ),
                _GroupActionsMenu(
                  onSelected: (_GroupMenuAction action) {
                    switch (action) {
                      case _GroupMenuAction.edit:
                        CustomerNavigator.openGroupForm(
                          context,
                          args: CustomerGroupFormArgs(groupId: group.id),
                        );
                        return;
                      case _GroupMenuAction.delete:
                        _confirmDelete(group);
                        return;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_GroupFilterResult>(
      context: context,
      builder: (context) {
        CustomerGroupStatus? tempStatus = _statusFilter;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Filter groups',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('All statuses'),
                      trailing: tempStatus == null
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () =>
                          setModalState(() => tempStatus = null),
                    ),
                    for (final s in CustomerGroupStatus.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(s.label),
                        trailing: tempStatus == s
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () =>
                            setModalState(() => tempStatus = s),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context)
                          .pop(_GroupFilterResult(status: tempStatus)),
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

    if (result == null || !mounted) return;
    setState(() {
      _statusFilter = result.status;
      _currentPage = 1;
    });
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<_GroupSortOption>(
      context: context,
      builder: (context) {
        _GroupSortOption temp = _sortOption;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Sort groups',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    for (final option in _GroupSortOption.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(option.label),
                        trailing:
                            temp == option ? const Icon(Icons.check) : null,
                        onTap: () => setModalState(() => temp = option),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(temp),
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

    if (selected == null || !mounted) return;
    setState(() {
      _sortOption = selected;
      _currentPage = 1;
    });
  }

  Future<void> _confirmDelete(CustomerGroup group) async {
    final count = _store.customerCountForGroup(group.id);
    if (count > 0) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Can\'t delete group'),
          content: Text(
              '"${group.name}" has $count customer${count != 1 ? 's' : ''}. Reassign them first.'),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete group?'),
            content:
                Text('Delete "${group.name}"? This can\'t be undone.'),
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
          ),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    try {
      await _store.deleteCustomerGroup(group.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${group.name}".')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _goToHome() {
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name == CustomerNavigator.homeRoute ||
          route.isFirst,
    );
  }

  int _totalPages(int count) =>
      count == 0 ? 0 : ((count - 1) ~/ _pageSize) + 1;

  List<CustomerGroup> _pageItems(
      List<CustomerGroup> items, int page, int pageSize) {
    final start = (page - 1) * pageSize;
    if (start >= items.length) return const <CustomerGroup>[];
    return items.sublist(start, (start + pageSize).clamp(0, items.length));
  }
}

enum _GroupMenuAction { edit, delete }

class _GroupActionsMenu extends StatelessWidget {
  const _GroupActionsMenu({required this.onSelected});

  final ValueChanged<_GroupMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_GroupMenuAction>(
      tooltip: 'Group actions',
      padding: EdgeInsets.zero,
      iconSize: 20,
      onSelected: onSelected,
      itemBuilder: (context) => const <PopupMenuEntry<_GroupMenuAction>>[
        PopupMenuItem<_GroupMenuAction>(
          value: _GroupMenuAction.edit,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
          ),
        ),
        PopupMenuItem<_GroupMenuAction>(
          value: _GroupMenuAction.delete,
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

class _GroupColorDot extends StatelessWidget {
  const _GroupColorDot({this.colorHex});

  final String? colorHex;

  @override
  Widget build(BuildContext context) {
    Color color;
    try {
      color = colorHex != null
          ? Color(int.parse(colorHex!.replaceFirst('#', '0xFF')))
          : Theme.of(context).colorScheme.primary;
    } catch (_) {
      color = Theme.of(context).colorScheme.primary;
    }

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
