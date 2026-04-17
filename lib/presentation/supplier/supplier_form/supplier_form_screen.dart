import 'package:flutter/material.dart';
import '../../../domain/entity/supplier/supplier.dart';
import '../../../domain/entity/supplier/supplier_upsert_payload.dart';
import '../../../core/stores/supplier/supplier_store.dart';
import 'widgets/supplier_form_body.dart';

class SupplierFormScreen extends StatefulWidget {
  final SupplierStore store;
  final Supplier? supplier; // null = create mode

  const SupplierFormScreen({
    super.key,
    required this.store,
    this.supplier,
  });

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _taxCodeCtrl;
  late final TextEditingController _idCardCtrl;
  late final TextEditingController _bankNameCtrl;
  late final TextEditingController _bankAccountCtrl;
  late final TextEditingController _bankNoteCtrl;

  bool _isSaving = false;
  bool get _isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _codeCtrl = TextEditingController(text: s?.code ?? '');
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _addressCtrl = TextEditingController(text: s?.address ?? '');
    _taxCodeCtrl = TextEditingController(text: s?.taxCode ?? '');
    _idCardCtrl = TextEditingController(text: s?.idCard ?? '');
    _bankNameCtrl = TextEditingController(text: s?.bankName ?? '');
    _bankAccountCtrl = TextEditingController(text: s?.bankAccount ?? '');
    _bankNoteCtrl = TextEditingController(text: s?.bankNote ?? '');
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _taxCodeCtrl.dispose();
    _idCardCtrl.dispose();
    _bankNameCtrl.dispose();
    _bankAccountCtrl.dispose();
    _bankNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = SupplierUpsertPayload(
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
      taxCode: _taxCodeCtrl.text.trim().isEmpty ? null : _taxCodeCtrl.text.trim(),
      idCard: _idCardCtrl.text.trim().isEmpty ? null : _idCardCtrl.text.trim(),
      bankName: _bankNameCtrl.text.trim().isEmpty ? null : _bankNameCtrl.text.trim(),
      bankAccount: _bankAccountCtrl.text.trim().isEmpty ? null : _bankAccountCtrl.text.trim(),
      bankNote: _bankNoteCtrl.text.trim().isEmpty ? null : _bankNoteCtrl.text.trim(),
    );

    bool success;
    if (_isEditing) {
      success = await widget.store.updateSupplier(widget.supplier!.id, payload);
    } else {
      success = await widget.store.addSupplier(payload);
    }

    setState(() => _isSaving = false);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Supplier updated' : 'Supplier created'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.store.errorMessage ?? 'An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Supplier' : 'New Supplier'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text('Save',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: SupplierFormBody(
        formKey: _formKey,
        codeCtrl: _codeCtrl,
        nameCtrl: _nameCtrl,
        phoneCtrl: _phoneCtrl,
        emailCtrl: _emailCtrl,
        addressCtrl: _addressCtrl,
        taxCodeCtrl: _taxCodeCtrl,
        idCardCtrl: _idCardCtrl,
        bankNameCtrl: _bankNameCtrl,
        bankAccountCtrl: _bankAccountCtrl,
        bankNoteCtrl: _bankNoteCtrl,
        isSaving: _isSaving,
        isEditing: _isEditing,
        onSubmit: _submit,
      ),
    );
  }
}
