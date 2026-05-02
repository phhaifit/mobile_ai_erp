import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_group.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_navigator.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_route_args.dart';
import 'package:mobile_ai_erp/presentation/customer_management/store/customer_store.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_empty_state.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_list_controls.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_status_chip.dart';

class CustomerGroupsScreen extends StatefulWidget {
  const CustomerGroupsScreen({super.key});

  @override
  State<CustomerGroupsScreen> createState() => _CustomerGroupsScreenState();
}

class _CustomerGroupsScreenState extends State<CustomerGroupsScreen> {
  final CustomerStore _store = getIt<CustomerStore>();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _reload());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _reload({int page = 1}) {
    _store.loadGroups(page: page, search: _query.isEmpty ? null : _query);
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
          final groups = _store.groups.toList();
          final totalPages = _store.groupTotalPages;
          final currentPage = _store.groupCurrentPage;
          final totalItems = _store.groupTotalItems;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: <Widget>[
              CustomerListControls(
                searchController: _searchController,
                onSearchChanged: (value) {
                  _debounce?.cancel();

                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    setState(() {
                      _query = value.trim();
                    });

                    _reload();
                  });
                },
                searchHint: 'Search by group name',
                resultLabel: 'Showing ${groups.length} of $totalItems groups',
                hasActiveFilter: false,
                hasCustomSort: false,
                onOpenFilter: null,
                onOpenSort: null,
              ),
              const SizedBox(height: 16),
              if (_store.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (groups.isEmpty)
                CustomerEmptyState(
                  icon: Icons.group_work_outlined,
                  title: _query.isNotEmpty
                      ? 'No matching groups'
                      : 'No groups yet',
                  message: _query.isNotEmpty
                      ? 'Try changing your search.'
                      : 'Add the first customer group to start segmenting.',
                )
              else ...<Widget>[
                ...groups.map(_buildGroupCard),
                if (totalPages > 1)
                  CustomerPaginationControls(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPrevious: currentPage > 1
                        ? () => _reload(page: currentPage - 1)
                        : null,
                    onNext: currentPage < totalPages
                        ? () => _reload(page: currentPage + 1)
                        : null,
                  ),
              ],
            ],
          );
        },
      ),
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (group.description != null &&
                          group.description!.trim().isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          group.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                            label: '$count customer${count != 1 ? 's' : ''}',
                          ),
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

  Future<void> _confirmDelete(CustomerGroup group) async {
    final count = _store.customerCountForGroup(group.id);

    if (count > 0) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Can\'t delete group'),
          content: Text(
            '"${group.name}" has $count customer${count != 1 ? 's' : ''}. Reassign them first.',
          ),
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

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete group?'),
            content: Text('Delete "${group.name}"? This can\'t be undone.'),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted "${group.name}".')));

      _reload();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _goToHome() {
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name == CustomerNavigator.homeRoute || route.isFirst,
    );
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
      itemBuilder: (context) => <PopupMenuEntry<_GroupMenuAction>>[
        const PopupMenuItem<_GroupMenuAction>(
          value: _GroupMenuAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 12),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem<_GroupMenuAction>(
          value: _GroupMenuAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 12),
              Text('Delete'),
            ],
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
