import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/exchange_request.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/refund_request.dart';
import 'package:mobile_ai_erp/presentation/post_purchase/store/post_purchase_store.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class IssueDetailScreen extends StatefulWidget {
  const IssueDetailScreen({super.key});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final PostPurchaseStore _store = getIt<PostPurchaseStore>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocus = FocusNode();
  String? _issueId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id != null && id != _issueId) {
      _issueId = id;
      _load(id);
    }
  }

  Future<void> _load(String id) async {
    await Future.wait([
      _store.getIssueDetail(id),
      _store.getExchanges(),
      _store.getRefunds(),
    ]);
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final issue = _store.selectedIssue;
    if (issue == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Issue Detail'),
          actions: _buildQuickActions(),
        ),
        body: const Center(child: Text('Issue not found.')),
      );
    }

    if (!_notesFocus.hasFocus &&
        _notesController.text != (issue.adminNotes ?? '')) {
      _notesController.text = issue.adminNotes ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Detail'),
        actions: _buildQuickActions(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Issue Info'),
          const SizedBox(height: 8),
          _buildInfoCard(issue),
          const SizedBox(height: 16),
          _buildSectionTitle('Issue Stepper'),
          const SizedBox(height: 8),
          _buildIssueStepper(issue.status),
          const SizedBox(height: 16),
          _buildSectionTitle('Available Actions'),
          const SizedBox(height: 8),
          _buildIssueActions(issue),
          const SizedBox(height: 16),
          _buildSectionTitle('Linked Action'),
          const SizedBox(height: 8),
          _buildLinkedActionCard(issue),
          const SizedBox(height: 16),
          _buildSectionTitle('Admin Notes'),
          const SizedBox(height: 8),
          _buildNotesEditor(issue),
          const SizedBox(height: 16),
          _buildSectionTitle('History (Placeholder)'),
          const SizedBox(height: 8),
          const Text('History tracking will be added in a later iteration.'),
        ],
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
        onPressed: () => Navigator.of(context).pushNamed(Routes.postPurchase),
        icon: const Icon(Icons.support_agent_outlined),
      ),
    ];
  }

  Widget _buildInfoCard(IssueTicket issue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              issue.subject,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            _buildKeyValue('Issue ID', issue.id),
            _buildKeyValue('Order ID', issue.orderId),
            _buildKeyValue('Customer', issue.customerName),
            _buildKeyValue('Status', issue.status.displayName),
            _buildKeyValue('Priority', issue.priority.displayName),
            _buildKeyValue('Channel', issue.channel),
            _buildKeyValue('Created', _dateFormat.format(issue.createdAt)),
            _buildKeyValue('Updated', _dateFormat.format(issue.updatedAt)),
            const SizedBox(height: 6),
            Text(issue.description),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueStepper(IssueStatus current) {
    final statuses = <IssueStatus>[
      IssueStatus.open,
      IssueStatus.investigating,
      IssueStatus.waitingCustomer,
      IssueStatus.pendingExchange,
      IssueStatus.pendingRefund,
      IssueStatus.resolved,
      IssueStatus.closed,
    ];
    final currentIndex = statuses.indexOf(current);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCurrent = currentIndex == index;
            final isPast = currentIndex > index;
            final activeColor = isCurrent || isPast ? Colors.blue : Colors.grey;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      isCurrent
                          ? Icons.radio_button_checked
                          : isPast
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                      size: 18,
                      color: activeColor,
                    ),
                    if (index != statuses.length - 1)
                      Container(
                        width: 2,
                        height: 20,
                        color: activeColor.withValues(alpha: 0.4),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      status.displayName,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isCurrent ? Colors.blue : null,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIssueActions(IssueTicket issue) {
    final actions = _store.availableIssueActions(issue.status);
    if (actions.isEmpty) {
      return const Text('No actions available for current status.');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions.map((action) {
        return ElevatedButton(
          onPressed: () => _handleIssueAction(issue, action),
          child: Text(action.displayName),
        );
      }).toList(),
    );
  }

  Future<void> _handleIssueAction(IssueTicket issue, IssueAction action) async {
    if (action == IssueAction.createExchange) {
      await _showCreateExchangeDialog(issue);
      return;
    }
    if (action == IssueAction.createRefund) {
      await _showCreateRefundDialog(issue);
      return;
    }

    await _store.executeIssueAction(issue.id, action);
    await _store.getIssueDetail(issue.id);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _showCreateExchangeDialog(IssueTicket issue) async {
    final reasonController = TextEditingController(text: issue.subject);
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create Exchange'),
          content: TextField(
            controller: reasonController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final id = await _store.createExchangeFromIssue(
                  issueId: issue.id,
                  reason: reasonController.text.trim(),
                );
                if (!mounted) return;
                Navigator.of(ctx).pop();
                await _store.getIssueDetail(issue.id);
                await _store.getExchanges();
                setState(() {});
                if (id != null) {
                  Navigator.of(context).pushNamed(
                    Routes.postPurchaseExchangeDetail,
                    arguments: id,
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    reasonController.dispose();
  }

  Future<void> _showCreateRefundDialog(IssueTicket issue) async {
    final reasonController = TextEditingController(text: issue.subject);
    final amountController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create Refund'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Refund Amount (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                final id = await _store.createRefundFromIssue(
                  issueId: issue.id,
                  reason: reasonController.text.trim(),
                  refundAmount: amount,
                );
                if (!mounted) return;
                Navigator.of(ctx).pop();
                await _store.getIssueDetail(issue.id);
                await _store.getRefunds();
                setState(() {});
                if (id != null) {
                  Navigator.of(context).pushNamed(
                    Routes.postPurchaseRefundDetail,
                    arguments: id,
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
    reasonController.dispose();
    amountController.dispose();
  }

  Widget _buildLinkedActionCard(IssueTicket issue) {
    if (issue.linkedExchangeId != null) {
      final exchange = _store.findExchangeById(issue.linkedExchangeId);
      return Card(
        child: ListTile(
          title: Text('Exchange ${issue.linkedExchangeId}'),
          subtitle: Text(
            exchange == null
                ? 'Linked exchange'
                : '${exchange.status.displayName} - ${exchange.reason}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed(
              Routes.postPurchaseExchangeDetail,
              arguments: issue.linkedExchangeId,
            );
          },
        ),
      );
    }

    if (issue.linkedRefundId != null) {
      final refund = _store.findRefundById(issue.linkedRefundId);
      return Card(
        child: ListTile(
          title: Text('Refund ${issue.linkedRefundId}'),
          subtitle: Text(
            refund == null
                ? 'Linked refund'
                : '${refund.status.displayName} - ${refund.reason}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pushNamed(
              Routes.postPurchaseRefundDetail,
              arguments: issue.linkedRefundId,
            );
          },
        ),
      );
    }

    return const Text('No linked exchange/refund yet.');
  }

  Widget _buildNotesEditor(IssueTicket issue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _notesController,
          focusNode: _notesFocus,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add admin notes',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () async {
              await _store.updateIssueNotes(issue.id, _notesController.text.trim());
              await _store.getIssueDetail(issue.id);
              if (!mounted) return;
              _notesFocus.unfocus();
              setState(() {});
            },
            child: const Text('Save Notes'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildKeyValue(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              key,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
