import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/return_exchange_request.dart';
import 'package:mobile_ai_erp/presentation/post_purchase/store/post_purchase_store.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class PostPurchaseDashboardScreen extends StatefulWidget {
  const PostPurchaseDashboardScreen({super.key});

  @override
  State<PostPurchaseDashboardScreen> createState() =>
      _PostPurchaseDashboardScreenState();
}

class _PostPurchaseDashboardScreenState
    extends State<PostPurchaseDashboardScreen> {
  final PostPurchaseStore _store = getIt<PostPurchaseStore>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _store.getIssues();
    _store.getReturns();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post-Purchase & Issues'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Issues'),
              Tab(text: 'Returns & Exchanges'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildIssuesTab(),
            _buildReturnsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuesTab() {
    return Column(
      children: [
        _buildIssueSearch(),
        _buildIssueStatusFilters(),
        Expanded(child: _buildIssueList()),
      ],
    );
  }

  Widget _buildIssueSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        onChanged: _store.setIssueSearchQuery,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search by ID, order ID, or customer',
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildIssueStatusFilters() {
    return Observer(
      builder: (_) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip<IssueStatus?>(
                label: 'All',
                value: null,
                groupValue: _store.issueStatusFilter,
                onSelected: _store.setIssueStatusFilter,
              ),
              ...IssueStatus.values.map(
                (status) => _buildFilterChip<IssueStatus?>(
                  label: status.displayName,
                  value: status,
                  groupValue: _store.issueStatusFilter,
                  onSelected: _store.setIssueStatusFilter,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIssueList() {
    return Observer(
      builder: (_) {
        if (_store.isLoadingIssues) {
          return const Center(child: CircularProgressIndicator());
        }
        final issues = _store.filteredIssues;
        if (issues.isEmpty) {
          return const Center(child: Text('No issues found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          itemCount: issues.length,
          itemBuilder: (context, index) => _buildIssueCard(issues[index]),
        );
      },
    );
  }

  Widget _buildIssueCard(IssueTicket issue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _store.getIssueDetail(issue.id);
          Navigator.of(context).pushNamed(
            Routes.postPurchaseIssueDetail,
            arguments: issue.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      issue.subject,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  _buildIssueStatusChip(issue.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${issue.customerName} • ${issue.orderId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildPriorityChip(issue.priority),
                  const SizedBox(width: 8),
                  Text(
                    issue.channel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    _dateFormat.format(issue.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReturnsTab() {
    return Column(
      children: [
        _buildReturnSearch(),
        _buildReturnFilters(),
        Expanded(child: _buildReturnList()),
      ],
    );
  }

  Widget _buildReturnSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        onChanged: _store.setReturnSearchQuery,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search by ID, order ID, or customer',
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildReturnFilters() {
    return Observer(
      builder: (_) {
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  _buildFilterChip<ReturnType?>(
                    label: 'All Types',
                    value: null,
                    groupValue: _store.returnTypeFilter,
                    onSelected: _store.setReturnTypeFilter,
                  ),
                  ...ReturnType.values.map(
                    (type) => _buildFilterChip<ReturnType?>(
                      label: type.displayName,
                      value: type,
                      groupValue: _store.returnTypeFilter,
                      onSelected: _store.setReturnTypeFilter,
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  _buildFilterChip<ReturnStatus?>(
                    label: 'All Status',
                    value: null,
                    groupValue: _store.returnStatusFilter,
                    onSelected: _store.setReturnStatusFilter,
                  ),
                  ...ReturnStatus.values.map(
                    (status) => _buildFilterChip<ReturnStatus?>(
                      label: status.displayName,
                      value: status,
                      groupValue: _store.returnStatusFilter,
                      onSelected: _store.setReturnStatusFilter,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReturnList() {
    return Observer(
      builder: (_) {
        if (_store.isLoadingReturns) {
          return const Center(child: CircularProgressIndicator());
        }
        final returns = _store.filteredReturns;
        if (returns.isEmpty) {
          return const Center(child: Text('No return or exchange requests.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          itemCount: returns.length,
          itemBuilder: (context, index) => _buildReturnCard(returns[index]),
        );
      },
    );
  }

  Widget _buildReturnCard(ReturnExchangeRequest req) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _store.getReturnDetail(req.id);
          Navigator.of(context).pushNamed(
            Routes.postPurchaseReturnDetail,
            arguments: req.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    req.id,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                  _buildReturnTypeChip(req.type),
                  const Spacer(),
                  _buildReturnStatusChip(req.status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${req.customerName} • ${req.orderId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      req.reason,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    _dateFormat.format(req.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (req.refundAmount != null)
                Text(
                  'Refund: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VND').format(req.refundAmount)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                )
              else if (req.exchangeSku != null)
                Text(
                  'Exchange SKU: ${req.exchangeSku}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueStatusChip(IssueStatus status) {
    final color = _issueStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReturnStatusChip(ReturnStatus status) {
    final color = _returnStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReturnTypeChip(ReturnType type) {
    final color = type == ReturnType.returnOnly ? Colors.blueGrey : Colors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(IssuePriority priority) {
    final color = _priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFilterChip<T>({
    required String label,
    required T value,
    required T groupValue,
    required void Function(T value) onSelected,
  }) {
    final isSelected = value == groupValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        checkmarkColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Color _issueStatusColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.newIssue:
        return Colors.orange;
      case IssueStatus.inReview:
        return Colors.blue;
      case IssueStatus.awaitingCustomer:
        return Colors.indigo;
      case IssueStatus.resolved:
        return Colors.green;
      case IssueStatus.closed:
        return Colors.grey;
    }
  }

  Color _returnStatusColor(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.requested:
        return Colors.orange;
      case ReturnStatus.approved:
        return Colors.blue;
      case ReturnStatus.inTransitBack:
        return Colors.teal;
      case ReturnStatus.received:
        return Colors.indigo;
      case ReturnStatus.refunded:
        return Colors.green;
      case ReturnStatus.exchanged:
        return Colors.purple;
      case ReturnStatus.rejected:
        return Colors.red;
    }
  }

  Color _priorityColor(IssuePriority priority) {
    switch (priority) {
      case IssuePriority.low:
        return Colors.green;
      case IssuePriority.medium:
        return Colors.orange;
      case IssuePriority.high:
        return Colors.red;
    }
  }
}
