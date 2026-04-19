import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_validation_exception.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_route_args.dart';
import 'package:mobile_ai_erp/presentation/customer_management/store/customer_store.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_form_decoration.dart';
import 'package:flutter/material.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key, this.args});

  final CustomerFormArgs? args;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final CustomerStore _store = getIt<CustomerStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  CustomerStatus _status = CustomerStatus.active;
  bool _isSaving = false;
  Customer? _editingCustomer;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await _store.loadDashboard();
    _editingCustomer =
        _store.findCustomerById(widget.args?.customerId);

    if (_editingCustomer != null) {
      _nameController.text = _editingCustomer!.name;
      _emailController.text = _editingCustomer!.email;
      _phoneController.text = _editingCustomer!.phone ?? '';
      _status = _editingCustomer!.status;
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _editingCustomer == null ? 'New customer' : 'Edit customer'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: customerFormDecoration(
                    labelText: 'Customer name'),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Customer name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration:
                    customerFormDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration:
                    customerFormDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CustomerStatus>(
                initialValue: _status,
                decoration: customerFormDecoration(labelText: 'Status'),
                items: CustomerStatus.values
                    .map(
                      (s) => DropdownMenuItem<CustomerStatus>(
                        value: s,
                        child: Text(s.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_editingCustomer == null
                    ? 'Create customer'
                    : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _store.saveCustomer(
        Customer(
          id: _editingCustomer?.id ?? '',
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _trimOrNull(_phoneController.text),
          status: _status,
          createdAt:
              _editingCustomer?.createdAt ?? DateTime.now(),
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } on CustomerValidationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Couldn\'t save customer. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _trimOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _DropdownLabel extends StatelessWidget {
  const _DropdownLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
    );
  }
}
