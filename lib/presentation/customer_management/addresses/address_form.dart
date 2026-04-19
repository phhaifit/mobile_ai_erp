import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/address/address.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_route_args.dart';
import 'package:mobile_ai_erp/presentation/customer_management/store/customer_store.dart';
import 'package:mobile_ai_erp/presentation/customer_management/widgets/customer_form_decoration.dart';
import 'package:flutter/material.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, required this.args});

  final AddressFormArgs args;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final CustomerStore _store = getIt<CustomerStore>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();

  bool _isSaving = false;
  Address? _editingAddress;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await _store.loadDashboard();
    if (widget.args.addressId != null) {
      _editingAddress = _store.activeAddresses
          .cast<Address?>()
          .firstWhere(
            (a) => a?.id == widget.args.addressId,
            orElse: () => null,
          );
      if (_editingAddress != null) {
        _addressController.text = _editingAddress!.address;
        _typeController.text = _editingAddress!.type;
        _provinceController.text = _editingAddress!.province ?? '';
        _districtController.text = _editingAddress!.district ?? '';
        _wardController.text = _editingAddress!.ward ?? '';
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _addressController.dispose();
    _typeController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _editingAddress == null ? 'New address' : 'Edit address'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              TextFormField(
                controller: _addressController,
                decoration:
                    customerFormDecoration(labelText: 'Full Address'),
                textCapitalization: TextCapitalization.sentences,
                minLines: 2,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration:
                    customerFormDecoration(labelText: 'Address Type (e.g. Residential, Business)'),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address type is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _provinceController,
                decoration:
                    customerFormDecoration(labelText: 'Province/State (optional)'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _districtController,
                decoration:
                    customerFormDecoration(labelText: 'District/County (optional)'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wardController,
                decoration:
                    customerFormDecoration(labelText: 'Ward/Subdivision (optional)'),
                textCapitalization: TextCapitalization.words,
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
                label: Text(_editingAddress == null
                    ? 'Create address'
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
      await _store.saveAddress(
        Address(
          id: _editingAddress?.id ?? '',
          address: _addressController.text.trim(),
          type: _typeController.text.trim(),
          province: _trimOrNull(_provinceController.text),
          district: _trimOrNull(_districtController.text),
          ward: _trimOrNull(_wardController.text),
          isDefault: _editingAddress?.isDefault ?? false,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Couldn\'t save address. Try again.')),
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
