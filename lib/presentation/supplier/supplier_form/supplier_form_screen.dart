import 'package:flutter/material.dart';
import '../../../domain/entity/supplier/supplier.dart';
import '../../../core/stores/supplier/supplier_store.dart';

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

  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;

  bool _isSaving = false;
  bool get _isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _contactCtrl = TextEditingController(text: s?.contactName ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _addressCtrl = TextEditingController(text: s?.address ?? '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    bool success;
    if (_isEditing) {
      final updated = widget.supplier!.copyWith(
        name: _nameCtrl.text.trim(),
        contactName: _contactCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      );
      success = await widget.store.updateSupplier(updated);
    } else {
      success = await widget.store.addSupplier(
        name: _nameCtrl.text.trim(),
        contactName: _contactCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      );
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionLabel('Basic Information'),
            const SizedBox(height: 12),
            _FormField(
              controller: _nameCtrl,
              label: 'Supplier Name',
              hint: 'e.g. Alpha Trading Co.',
              icon: Icons.business_outlined,
              isRequired: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Supplier name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _contactCtrl,
              label: 'Contact Person',
              hint: 'e.g. Nguyen Van A',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Contact Details'),
            const SizedBox(height: 12),
            _FormField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hint: 'e.g. 0901234567',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  final cleaned = v.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                  if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(cleaned)) {
                    return 'Enter a valid phone number';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'e.g. supplier@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                    return 'Enter a valid email address';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _FormField(
              controller: _addressCtrl,
              label: 'Address',
              hint: 'Street, District, City',
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Additional'),
            const SizedBox(height: 12),
            _FormField(
              controller: _notesCtrl,
              label: 'Notes',
              hint: 'Any additional information…',
              icon: Icons.notes_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSaving ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  _isEditing ? 'Update Supplier' : 'Create Supplier',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool isRequired;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.isRequired = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
