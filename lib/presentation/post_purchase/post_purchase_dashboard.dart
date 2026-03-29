import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/exchange_request.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/order_complaint_candidate.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/refund_request.dart';
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
    _load();
  }

  Future<void> _load() async {
    await _store.loadAll();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post-Purchase & Issue Management'),
          actions: _buildQuickActions(),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Issues'),
              Tab(text: 'Exchanges'),
              Tab(text: 'Refunds'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildIssuesTab(),
            _buildExchangesTab(),
            _buildRefundsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuesTab() {
    final issues = _store.filteredIssues;
    return Column(
      children: [
        _buildIssueSearch(),
        _buildIssueFilters(),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _showCreateIssueDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create Issue'),
            ),
          ),
        ),
        Expanded(
          child: _store.isLoadingIssues
              ? const Center(child: CircularProgressIndicator())
              : issues.isEmpty
              ? const Center(child: Text('No issues found.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: issues.length,
                  itemBuilder: (context, index) =>
                      _buildIssueCard(issues[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildIssueSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        onChanged: (value) {
          _store.issueSearchQuery = value;
          setState(() {});
        },
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search issue by id / order / customer / subject',
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildIssueFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: IssueFilterGroup.values.map((group) {
          final selected = _store.issueFilterGroup == group;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(group.displayName),
              selected: selected,
              onSelected: (_) {
                _store.issueFilterGroup = group;
                setState(() {});
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIssueCard(IssueTicket issue) {
    final linkedBadge = issue.linkedExchangeId != null
        ? 'EXC: ${issue.linkedExchangeId}'
        : issue.linkedRefundId != null
        ? 'RFD: ${issue.linkedRefundId}'
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await _store.getIssueDetail(issue.id);
          if (!mounted) return;
          await Navigator.of(
            context,
          ).pushNamed(Routes.postPurchaseIssueDetail, arguments: issue.id);
          if (!mounted) return;
          await _load();
        },
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
                  _buildStatusChip(
                    issue.status.displayName,
                    _issueStatusColor(issue.status),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${issue.id} - ${issue.orderId} - ${issue.customerName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (linkedBadge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        linkedBadge,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    _dateFormat.format(issue.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExchangesTab() {
    final exchanges = _store.filteredExchanges;
    return Column(
      children: [
        _buildExchangeSearch(),
        _buildExchangeFilters(),
        Expanded(
          child: _store.isLoadingExchanges
              ? const Center(child: CircularProgressIndicator())
              : exchanges.isEmpty
              ? const Center(child: Text('No exchanges found.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: exchanges.length,
                  itemBuilder: (context, index) =>
                      _buildExchangeCard(exchanges[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildExchangeSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        onChanged: (value) {
          _store.exchangeSearchQuery = value;
          setState(() {});
        },
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search exchange by id / order / customer / reason',
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildExchangeFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: ExchangeFilterGroup.values.map((group) {
          final selected = _store.exchangeFilterGroup == group;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(group.displayName),
              selected: selected,
              onSelected: (_) {
                _store.exchangeFilterGroup = group;
                setState(() {});
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExchangeCard(ExchangeRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await _store.getExchangeDetail(request.id);
          if (!mounted) return;
          await Navigator.of(
            context,
          ).pushNamed(Routes.postPurchaseExchangeDetail, arguments: request.id);
          if (!mounted) return;
          await _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${request.id} - ${request.orderId}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(
                    request.status.displayName,
                    _exchangeStatusColor(request.status),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                request.customerName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (request.linkedIssueId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'ISS: ${request.linkedIssueId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    _dateFormat.format(request.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefundsTab() {
    final refunds = _store.filteredRefunds;
    return Column(
      children: [
        _buildRefundSearch(),
        _buildRefundFilters(),
        Expanded(
          child: _store.isLoadingRefunds
              ? const Center(child: CircularProgressIndicator())
              : refunds.isEmpty
              ? const Center(child: Text('No refunds found.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: refunds.length,
                  itemBuilder: (context, index) =>
                      _buildRefundCard(refunds[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildRefundSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        onChanged: (value) {
          _store.refundSearchQuery = value;
          setState(() {});
        },
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Search refund by id / order / customer / reason',
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildRefundFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: RefundFilterGroup.values.map((group) {
          final selected = _store.refundFilterGroup == group;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(group.displayName),
              selected: selected,
              onSelected: (_) {
                _store.refundFilterGroup = group;
                setState(() {});
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRefundCard(RefundRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await _store.getRefundDetail(request.id);
          if (!mounted) return;
          await Navigator.of(
            context,
          ).pushNamed(Routes.postPurchaseRefundDetail, arguments: request.id);
          if (!mounted) return;
          await _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${request.id} - ${request.orderId}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(
                    request.status.displayName,
                    _refundStatusColor(request.status),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                request.customerName,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (request.linkedIssueId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'ISS: ${request.linkedIssueId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    _dateFormat.format(request.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _buildQuickActions() {
    return [
      IconButton(
        tooltip: 'Home',
        onPressed: () => Navigator.of(context).pushNamed(Routes.home),
        icon: const Icon(Icons.home_outlined),
      ),
      IconButton(
        tooltip: 'Post-Purchase',
        onPressed: () async {
          await _load();
        },
        icon: const Icon(Icons.support_agent_outlined),
      ),
    ];
  }

  Future<void> _showCreateIssueDialog() async {
    if (_store.orderPool.isEmpty) {
      await _store.getOrderPool();
      if (!mounted) return;
      setState(() {});
    }
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    final channelController = TextEditingController();
    IssuePriority priority = IssuePriority.medium;
    OrderComplaintCandidate? selectedOrder = _store.orderPool.isNotEmpty
        ? _store.orderPool.first
        : null;
    if (selectedOrder != null) {
      channelController.text = selectedOrder.preferredChannel;
    }

    await showDialog<void>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Issue'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<OrderComplaintCandidate>(
                      initialValue: selectedOrder,
                      items: _store.orderPool
                          .map(
                            (order) => DropdownMenuItem(
                              value: order,
                              child: Text(
                                '${order.orderId} - ${order.customerName}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedOrder = value;
                          channelController.text =
                              value?.preferredChannel ?? '';
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Order *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<IssuePriority>(
                      initialValue: priority,
                      items: IssuePriority.values
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => priority = value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Customer',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      child: Text(selectedOrder?.customerName ?? ''),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: channelController,
                      decoration: const InputDecoration(
                        labelText: 'Channel',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedOrder == null ||
                        subjectController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill required fields.'),
                        ),
                      );
                      return;
                    }
                    final id = await _store.createIssue(
                      orderId: selectedOrder!.orderId,
                      customerName: selectedOrder!.customerName,
                      subject: subjectController.text.trim(),
                      description: descriptionController.text.trim(),
                      priority: priority,
                      channel: channelController.text.trim(),
                    );
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    setState(() {});
                    if (id != null) {
                      await Navigator.of(this.context).pushNamed(
                        Routes.postPurchaseIssueDetail,
                        arguments: id,
                      );
                      if (!mounted) return;
                      await _load();
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    subjectController.dispose();
    descriptionController.dispose();
    channelController.dispose();
  }

  Color _issueStatusColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.open:
        return Colors.orange;
      case IssueStatus.investigating:
        return Colors.blue;
      case IssueStatus.waitingCustomer:
        return Colors.indigo;
      case IssueStatus.pendingExchange:
        return Colors.teal;
      case IssueStatus.pendingRefund:
        return Colors.deepPurple;
      case IssueStatus.resolved:
        return Colors.green;
      case IssueStatus.closed:
        return Colors.grey;
    }
  }

  Color _exchangeStatusColor(ExchangeStatus status) {
    switch (status) {
      case ExchangeStatus.requested:
        return Colors.orange;
      case ExchangeStatus.approved:
        return Colors.blue;
      case ExchangeStatus.awaitingReturn:
        return Colors.indigo;
      case ExchangeStatus.inTransitBack:
        return Colors.teal;
      case ExchangeStatus.received:
        return Colors.cyan;
      case ExchangeStatus.replacementShipped:
        return Colors.purple;
      case ExchangeStatus.completed:
        return Colors.green;
      case ExchangeStatus.rejected:
      case ExchangeStatus.cancelled:
        return Colors.red;
    }
  }

  Color _refundStatusColor(RefundStatus status) {
    switch (status) {
      case RefundStatus.requested:
        return Colors.orange;
      case RefundStatus.approved:
        return Colors.blue;
      case RefundStatus.awaitingReturn:
        return Colors.indigo;
      case RefundStatus.inTransitBack:
        return Colors.teal;
      case RefundStatus.received:
        return Colors.cyan;
      case RefundStatus.refundPending:
        return Colors.purple;
      case RefundStatus.refunded:
        return Colors.green;
      case RefundStatus.rejected:
      case RefundStatus.cancelled:
        return Colors.red;
    }
  }
}
