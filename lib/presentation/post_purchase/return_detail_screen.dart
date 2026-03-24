import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/post_purchase/return_exchange_request.dart';
import 'package:mobile_ai_erp/presentation/post_purchase/store/post_purchase_store.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

class ReturnDetailScreen extends StatefulWidget {
  const ReturnDetailScreen({super.key});

  @override
  State<ReturnDetailScreen> createState() => _ReturnDetailScreenState();
}

class _ReturnDetailScreenState extends State<ReturnDetailScreen> {
  final PostPurchaseStore _store = getIt<PostPurchaseStore>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocus = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id != null) {
      _store.getReturnDetail(id);
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
        title: const Text('Return / Exchange Detail'),
      ),
      body: Observer(
        builder: (_) {
          final req = _store.selectedReturn;
          if (req == null) {
            return const Center(child: Text('Request not found.'));
          }
          if (!_notesFocus.hasFocus &&
              _notesController.text != (req.adminNotes ?? '')) {
            _notesController.text = req.adminNotes ?? '';
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${req.type.displayName} Request',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${req.id} • Order ${req.orderId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Status'),
              const SizedBox(height: 8),
              _buildStatusDropdown(req),
              if (req.type == ReturnType.exchange) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => _store.convertExchangeToRefund(req.id),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Convert to Refund'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildSectionTitle('Customer'),
              const SizedBox(height: 8),
              _buildKeyValue('Name', req.customerName),
              _buildKeyValue('Requested', _dateFormat.format(req.requestedAt)),
              _buildKeyValue('Updated', _dateFormat.format(req.updatedAt)),
              if (req.linkedIssueId != null) ...[
                const SizedBox(height: 12),
                _buildSectionTitle('Linked Issue'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(req.linkedIssueId!)),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          Routes.postPurchaseIssueDetail,
                          arguments: req.linkedIssueId,
                        );
                      },
                      child: const Text('Open'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _buildSectionTitle('Reason'),
              const SizedBox(height: 8),
              Text(req.reason),
              if (req.notes != null) ...[
                const SizedBox(height: 12),
                _buildSectionTitle('Notes'),
                const SizedBox(height: 8),
                Text(req.notes!),
              ],
              const SizedBox(height: 16),
              _buildSectionTitle('Items'),
              const SizedBox(height: 8),
              ...req.items.map(_buildItemRow),
              const SizedBox(height: 16),
              if (req.refundAmount != null)
                _buildKeyValue(
                  'Refund',
                  _currencyFormat.format(req.refundAmount),
                ),
              if (req.exchangeSku != null)
                _buildKeyValue('Exchange SKU', req.exchangeSku!),
              const SizedBox(height: 16),
              _buildSectionTitle('Admin Notes'),
              const SizedBox(height: 8),
              _buildNotesEditor(req),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusDropdown(ReturnExchangeRequest req) {
    final statuses = req.type == ReturnType.exchange
        ? ReturnStatus.values
            .where((s) => s != ReturnStatus.refunded)
            .toList()
        : ReturnStatus.values.toList();
    return DropdownButtonFormField<ReturnStatus>(
      value: req.status,
      items: statuses
          .map(
            (status) => DropdownMenuItem(
              value: status,
              child: Text(status.displayName),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        _store.updateReturnStatus(req.id, value);
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _buildItemRow(ReturnLineItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text('${item.name} (${item.sku})'),
          ),
          Text('x${item.quantity}'),
        ],
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

  Widget _buildKeyValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
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

  Widget _buildNotesEditor(ReturnExchangeRequest req) {
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
              _store.updateReturnNotes(req.id, _notesController.text.trim());
              _notesFocus.unfocus();
            },
            child: const Text('Save Notes'),
          ),
        ),
      ],
    );
  }
}
