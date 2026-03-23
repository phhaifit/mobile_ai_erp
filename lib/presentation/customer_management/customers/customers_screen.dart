import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_navigator.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_route_args.dart';
import 'package:mobile_ai_erp/presentation/customer_management/store/customer_store.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_empty_state.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_list_controls.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_pagination_controls.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

enum _CustomerSortOption {
  nameAsc('Name A-Z'),
  nameDesc('Name Z-A'),
  newest('Newest first'),
  oldest('Oldest first');

  const _CustomerSortOption(this.label);

  final String label;
}

class _CustomerFilterResult {
  const _CustomerFilterResult({this.status, this.groupId});

  final CustomerStatus? status;
  final String? groupId;
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  static const int _pageSize = 10;

  final CustomerStore _store = getIt<CustomerStore>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  CustomerStatus? _statusFilter;
  String? _groupFilter;
  _CustomerSortOption _sortOption = _CustomerSortOption.nameAsc;
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
        title: const Text('Customers'),
        actions: <Widget>[
          IconButton(
            onPressed: _goToHome,
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Back to Customer Management',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CustomerNavigator.openCustomerForm(context),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add customer'),
      ),
      body: Observer(
        builder: (context) {
          if (_store.isLoading && !_store.hasLoadedDashboard) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = _applyFilters(_store.customers.toList());
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
                searchHint: 'Search by name, email, or phone',
                resultLabel:
                    'Showing ${visible.length} of ${filtered.length} customers',
                hasActiveFilter:
                    _statusFilter != null || _groupFilter != null,
                hasCustomSort: _sortOption != _CustomerSortOption.nameAsc,
                onOpenFilter: _openFilterSheet,
                onOpenSort: _openSortSheet,
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                CustomerEmptyState(
                  icon: Icons.people_outline,
                  title: _query.isNotEmpty ||
                          _statusFilter != null ||
                          _groupFilter != null
                      ? 'No matching customers'
                      : 'No customers yet',
                  message: _query.isNotEmpty ||
                          _statusFilter != null ||
                          _groupFilter != null
                      ? 'Try changing your search or filters.'
                      : 'Add the first customer to get started.',
                )
              else ...<Widget>[
                ...visible.map(_buildCustomerCard),
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

  List<Customer> _applyFilters(List<Customer> source) {
    final query = _query.toLowerCase();
    final filtered = source.where((c) {
      if (_statusFilter != null && c.status != _statusFilter) return false;
      if (_groupFilter != null && c.groupId != _groupFilter) return false;
      if (query.isEmpty) return true;
      return c.fullName.toLowerCase().contains(query) ||
          c.email.toLowerCase().contains(query) ||
          (c.phone?.toLowerCase().contains(query) ?? false);
    }).toList();

    filtered.sort((a, b) {
      switch (_sortOption) {
        case _CustomerSortOption.nameAsc:
          return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
        case _CustomerSortOption.nameDesc:
          return b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase());
        case _CustomerSortOption.newest:
          return b.createdAt.compareTo(a.createdAt);
        case _CustomerSortOption.oldest:
          return a.createdAt.compareTo(b.createdAt);
      }
    });

    return filtered;
  }

  Widget _buildCustomerCard(Customer customer) {
    final group = _store.findGroupById(customer.groupId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => CustomerNavigator.openCustomerDetail(
            context,
            args: CustomerDetailArgs(customerId: customer.id),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: <Widget>[
                _CustomerAvatar(customer: customer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        customer.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: <Widget>[
                          CustomerStatusChip(label: customer.status.label),
                          CustomerStatusChip(label: customer.type.label),
                          if (group != null)
                            CustomerStatusChip(label: group.name),
                        ],
                      ),
                    ],
                  ),
                ),
                _CustomerActionsMenu(
                  onSelected: (_CustomerMenuAction action) {
                    switch (action) {
                      case _CustomerMenuAction.edit:
                        CustomerNavigator.openCustomerForm(
                          context,
                          args: CustomerFormArgs(customerId: customer.id),
                        );
                        return;
                      case _CustomerMenuAction.delete:
                        _confirmDelete(customer);
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
    final result = await showModalBottomSheet<_CustomerFilterResult>(
      context: context,
      builder: (context) {
        CustomerStatus? tempStatus = _statusFilter;
        String? tempGroup = _groupFilter;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Filter customers',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Text('Status',
                        style: Theme.of(context).textTheme.labelMedium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('All statuses'),
                      trailing: tempStatus == null
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () =>
                          setModalState(() => tempStatus = null),
                    ),
                    for (final s in CustomerStatus.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(s.label),
                        trailing:
                            tempStatus == s ? const Icon(Icons.check) : null,
                        onTap: () => setModalState(() => tempStatus = s),
                      ),
                    const Divider(),
                    Text('Group',
                        style: Theme.of(context).textTheme.labelMedium),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('All groups'),
                      trailing:
                          tempGroup == null ? const Icon(Icons.check) : null,
                      onTap: () =>
                          setModalState(() => tempGroup = null),
                    ),
                    for (final g in _store.groups)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(g.name),
                        trailing: tempGroup == g.id
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => setModalState(() => tempGroup = g.id),
                      ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(
                        _CustomerFilterResult(
                            status: tempStatus, groupId: tempGroup),
                      ),
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
      _groupFilter = result.groupId;
      _currentPage = 1;
    });
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<_CustomerSortOption>(
      context: context,
      builder: (context) {
        _CustomerSortOption temp = _sortOption;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Sort customers',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    for (final option in _CustomerSortOption.values)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(option.label),
                        trailing: temp == option
                            ? const Icon(Icons.check)
                            : null,
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

  Future<void> _confirmDelete(Customer customer) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete customer?'),
            content: Text(
                'Delete "${customer.fullName}"? This will also remove their addresses and cannot be undone.'),
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
      await _store.deleteCustomer(customer.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${customer.fullName}".')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Couldn\'t delete customer. Try again.')),
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

  List<Customer> _pageItems(List<Customer> items, int page, int pageSize) {
    final start = (page - 1) * pageSize;
    if (start >= items.length) return const <Customer>[];
    return items.sublist(start, (start + pageSize).clamp(0, items.length));
  }
}

enum _CustomerMenuAction { edit, delete }

class _CustomerActionsMenu extends StatelessWidget {
  const _CustomerActionsMenu({required this.onSelected});

  final ValueChanged<_CustomerMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CustomerMenuAction>(
      tooltip: 'Customer actions',
      padding: EdgeInsets.zero,
      iconSize: 20,
      onSelected: onSelected,
      itemBuilder: (context) =>
          const <PopupMenuEntry<_CustomerMenuAction>>[
        PopupMenuItem<_CustomerMenuAction>(
          value: _CustomerMenuAction.edit,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
          ),
        ),
        PopupMenuItem<_CustomerMenuAction>(
          value: _CustomerMenuAction.delete,
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

class _CustomerAvatar extends StatelessWidget {
  const _CustomerAvatar({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 22,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        customer.initials,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
