import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_validation_exception.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_navigator.dart';
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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  CustomerStatus _status = CustomerStatus.active;
  String? _selectedGroupId;
  bool _isSaving = false;
  bool _isLoading = false;
  Customer? _editingCustomer;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.args?.customerId != null;
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    final customerId = widget.args?.customerId;
    if (customerId != null) {
      await Future.wait([
        _store.loadCustomerDetail(customerId),
        _store.loadGroups(),
      ]);
    } else {
      await _store.loadGroups();
    }
    _editingCustomer = _store.findCustomerById(customerId);

    if (_editingCustomer != null) {
      _firstNameController.text = _editingCustomer!.firstName;
      _lastNameController.text = _editingCustomer!.lastName;
      _emailController.text = _editingCustomer!.email;
      _phoneController.text = _editingCustomer!.phone ?? '';
      _notesController.text = _editingCustomer!.notes ?? '';
      _status = _editingCustomer!.status;
      _selectedGroupId = _editingCustomer!.groupId;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.args?.customerId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit customer' : 'New customer'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: customerFormDecoration(
                        labelText: 'First name',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if ((value == null || value.trim().isEmpty) &&
                            (_lastNameController.text.trim().isEmpty)) {
                          return 'Required.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: customerFormDecoration(
                        labelText: 'Last name',
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: customerFormDecoration(labelText: 'Email'),
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
                decoration: customerFormDecoration(
                  labelText: 'Phone (optional)',
                ),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                isExpanded: true,
                initialValue: _selectedGroupId,
                decoration: customerFormDecoration(labelText: 'Group'),
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: _DropdownLabel('No group'),
                  ),
                  ..._store.groups.map(
                    (g) => DropdownMenuItem<String?>(
                      value: g.id,
                      child: _DropdownLabel(g.name),
                    ),
                  ),
                ],
                selectedItemBuilder: (context) => <Widget>[
                  const _DropdownLabel('No group'),
                  ..._store.groups.map((g) => _DropdownLabel(g.name)),
                ],
                onChanged: (value) => setState(() => _selectedGroupId = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: customerFormDecoration(
                  labelText: 'Notes (optional)',
                ),
                minLines: 2,
                maxLines: 4,
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
                label: Text(
                  _editingCustomer == null ? 'Create customer' : 'Save changes',
                ),
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
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _trimOrNull(_phoneController.text),
          groupId: _selectedGroupId,
          notes: _trimOrNull(_notesController.text),
          status: _status,
          createdAt: _editingCustomer?.createdAt ?? DateTime.now(),
        ),
      );

      if (!mounted) return;

      // Reload customers list to update pagination
      await _store.loadCustomers();

      if (!mounted) return;

      Navigator.popUntil(
        context,
        (route) => route.settings.name == CustomerNavigator.customersRoute,
      );
    } on CustomerValidationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t save customer. Try again.')),
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