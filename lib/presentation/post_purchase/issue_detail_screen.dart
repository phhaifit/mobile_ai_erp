import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/issue_ticket.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id != null) {
      _store.getIssueDetail(id);
    }
    if (_store.returnList.isEmpty) {
      _store.getReturns();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Detail'),
      ),
      body: Observer(
        builder: (_) {
          final issue = _store.selectedIssue;
          if (issue == null) {
            return const Center(child: Text('Issue not found.'));
          }
          if (!_notesFocus.hasFocus &&
              _notesController.text != (issue.adminNotes ?? '')) {
            _notesController.text = issue.adminNotes ?? '';
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                issue.subject,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Order ${issue.orderId} • ${issue.customerName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Status'),
              const SizedBox(height: 8),
              _buildStatusDropdown(issue),
              const SizedBox(height: 16),
              _buildSectionTitle('Details'),
              const SizedBox(height: 8),
              _buildKeyValue('Priority', issue.priority.displayName),
              _buildKeyValue('Channel', issue.channel),
              _buildKeyValue('Assignee', issue.assignee ?? 'Unassigned'),
              _buildKeyValue('Created', _dateFormat.format(issue.createdAt)),
              _buildKeyValue('Updated', _dateFormat.format(issue.updatedAt)),
              const SizedBox(height: 16),
              _buildSectionTitle('Return / Exchange'),
              const SizedBox(height: 8),
              _buildLinkedReturnSection(issue),
              const SizedBox(height: 16),
              _buildSectionTitle('Description'),
              const SizedBox(height: 8),
              Text(issue.description),
              const SizedBox(height: 16),
              _buildSectionTitle('Admin Notes'),
              const SizedBox(height: 8),
              _buildNotesEditor(issue),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusDropdown(IssueTicket issue) {
    return DropdownButtonFormField<IssueStatus>(
      value: issue.status,
      items: IssueStatus.values
          .map(
            (status) => DropdownMenuItem(
              value: status,
              child: Text(status.displayName),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        _store.updateIssueStatus(issue.id, value);
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildLinkedReturnSection(IssueTicket issue) {
    if (issue.linkedReturnId != null) {
      return Row(
        children: [
          Expanded(
            child: Text(
              'Linked: ${issue.linkedReturnId}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                Routes.postPurchaseReturnDetail,
                arguments: issue.linkedReturnId,
              );
            },
            child: const Text('Open'),
          ),
        ],
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () => _showLinkReturnDialog(issue.id),
        icon: const Icon(Icons.link),
        label: const Text('Link Return/Exchange'),
      ),
    );
  }

  void _showLinkReturnDialog(String issueId) {
    final returns = _store.returnList.toList();
    showDialog<void>(
      context: context,
      builder: (context) {
        if (returns.isEmpty) {
          return AlertDialog(
            title: const Text('Link Return/Exchange'),
            content: const Text('No return/exchange requests available.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }
        return SimpleDialog(
          title: const Text('Select Return/Exchange'),
          children: returns
              .map(
                (item) => SimpleDialogOption(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _store.linkIssueToReturn(issueId, item.id);
                  },
                  child: Text('${item.id} • ${item.customerName}'),
                ),
              )
              .toList(),
        );
      },
    );
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
            hintText: 'Add internal notes',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              _store.updateIssueNotes(issue.id, _notesController.text.trim());
              _notesFocus.unfocus();
            },
            child: const Text('Save Notes'),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
