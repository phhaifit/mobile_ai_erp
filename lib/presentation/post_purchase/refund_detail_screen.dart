import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/refund_request.dart';
import 'package:mobile_ai_erp/presentation/post_purchase/store/post_purchase_store.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class RefundDetailScreen extends StatefulWidget {
  const RefundDetailScreen({super.key});

  @override
  State<RefundDetailScreen> createState() => _RefundDetailScreenState();
}

class _RefundDetailScreenState extends State<RefundDetailScreen> {
  final PostPurchaseStore _store = getIt<PostPurchaseStore>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final NumberFormat _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocus = FocusNode();
  String? _refundId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id != null && id != _refundId) {
      _refundId = id;
      _load(id);
    }
  }

  Future<void> _load(String id) async {
    await Future.wait([
      _store.getRefundDetail(id),
      _store.getIssues(),
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
    final refund = _store.selectedRefund;
    if (refund == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Refund Detail'),
          actions: _buildQuickActions(),
        ),
        body: const Center(child: Text('Refund not found.')),
      );
    }

    if (!_notesFocus.hasFocus && _notesController.text != (refund.adminNotes ?? '')) {
      _notesController.text = refund.adminNotes ?? '';
    }

    final isTerminal = refund.status == RefundStatus.rejected ||
        refund.status == RefundStatus.cancelled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Refund Detail'),
        actions: _buildQuickActions(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Refund Info'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${refund.id} - ${refund.orderId}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      if (isTerminal) _terminalBadge(refund.status.displayName),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildKeyValue('Customer', refund.customerName),
                  _buildKeyValue('Status', refund.status.displayName),
                  _buildKeyValue('Reason', refund.reason),
                  _buildKeyValue('Requested', _dateFormat.format(refund.requestedAt)),
                  _buildKeyValue('Updated', _dateFormat.format(refund.updatedAt)),
                  if (refund.refundAmount != null)
                    _buildKeyValue('Amount', _currency.format(refund.refundAmount)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Refund Stepper'),
          const SizedBox(height: 8),
          _buildStepper(refund.status),
          const SizedBox(height: 16),
          _buildSectionTitle('Available Actions'),
          const SizedBox(height: 8),
          _buildActions(refund),
          const SizedBox(height: 16),
          _buildSectionTitle('Linked Issue'),
          const SizedBox(height: 8),
          _buildLinkedIssue(refund.linkedIssueId),
          const SizedBox(height: 16),
          _buildSectionTitle('Admin Notes'),
          const SizedBox(height: 8),
          _buildNotes(refund),
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

  Widget _buildStepper(RefundStatus current) {
    final flow = <RefundStatus>[
      RefundStatus.requested,
      RefundStatus.approved,
      RefundStatus.awaitingReturn,
      RefundStatus.inTransitBack,
      RefundStatus.received,
      RefundStatus.refundPending,
      RefundStatus.refunded,
    ];
    final currentIndex = flow.indexOf(current);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: flow.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCurrent = currentIndex == index;
            final isDone = currentIndex > index;
            final color = isCurrent || isDone ? Colors.blue : Colors.grey;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      isCurrent
                          ? Icons.radio_button_checked
                          : isDone
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                      size: 18,
                      color: color,
                    ),
                    if (index != flow.length - 1)
                      Container(
                        width: 2,
                        height: 20,
                        color: color.withValues(alpha: 0.4),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(status.displayName)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActions(RefundRequest refund) {
    final actions = _store.availableRefundActions(refund.status);
    if (actions.isEmpty) return const Text('No actions available.');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions.map((action) {
        return ElevatedButton(
          onPressed: () async {
            await _store.executeRefundAction(refund.id, action);
            await _store.getRefundDetail(refund.id);
            if (!mounted) return;
            setState(() {});
          },
          child: Text(action.displayName),
        );
      }).toList(),
    );
  }

  Widget _buildLinkedIssue(String? issueId) {
    if (issueId == null) return const Text('No linked issue.');
    final issue = _store.findIssueById(issueId);
    return Card(
      child: ListTile(
        title: Text('Issue $issueId'),
        subtitle: Text(issue == null ? 'Linked issue' : issue.status.displayName),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).pushNamed(
            Routes.postPurchaseIssueDetail,
            arguments: issueId,
          );
        },
      ),
    );
  }

  Widget _buildNotes(RefundRequest refund) {
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
              await _store.updateRefundNotes(refund.id, _notesController.text.trim());
              await _store.getRefundDetail(refund.id);
              if (!mounted) return;
              setState(() {});
            },
            child: const Text('Save Notes'),
          ),
        ),
      ],
    );
  }

  Widget _terminalBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
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
          SizedBox(width: 120, child: Text(key)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
