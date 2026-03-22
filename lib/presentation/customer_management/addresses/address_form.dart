import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/customer/address.dart';
import 'package:mobile_ai_erp/domain/entity/customer/customer_validation_exception.dart';
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
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();

  AddressType _type = AddressType.both;
  bool _isDefault = false;
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
        _labelController.text = _editingAddress!.label;
        _streetController.text = _editingAddress!.street;
        _cityController.text = _editingAddress!.city;
        _stateController.text = _editingAddress!.state ?? '';
        _countryController.text = _editingAddress!.countryCode;
        _postalController.text = _editingAddress!.postalCode ?? '';
        _type = _editingAddress!.type;
        _isDefault = _editingAddress!.isDefault;
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalController.dispose();
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
                controller: _labelController,
                decoration:
                    customerFormDecoration(labelText: 'Label (e.g. Home, Office)'),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Label is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AddressType>(
                initialValue: _type,
                decoration: customerFormDecoration(labelText: 'Address type'),
                items: AddressType.values
                    .map(
                      (t) => DropdownMenuItem<AddressType>(
                        value: t,
                        child: Text(t.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                decoration: customerFormDecoration(
                    labelText: 'Street address'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Street is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cityController,
                      decoration:
                          customerFormDecoration(labelText: 'City'),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'City is required.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: customerFormDecoration(
                          labelText: 'State / Province'),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _countryController,
                      decoration: customerFormDecoration(
                          labelText: 'Country code (e.g. US, VN)'),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Country is required.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _postalController,
                      decoration: customerFormDecoration(
                          labelText: 'Postal code'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as default address'),
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
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
                    ? 'Add address'
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
          customerId: widget.args.customerId,
          label: _labelController.text.trim(),
          type: _type,
          street: _streetController.text.trim(),
          city: _cityController.text.trim(),
          state: _trimOrNull(_stateController.text),
          countryCode: _countryController.text.trim().toUpperCase(),
          postalCode: _trimOrNull(_postalController.text),
          isDefault: _isDefault,
        ),
      );

      if (_isDefault && mounted) {
        final savedAddr = _store.activeAddresses
            .cast<Address?>()
            .firstWhere(
              (a) => a?.label == _labelController.text.trim(),
              orElse: () => null,
            );
        if (savedAddr != null) {
          await _store.setDefaultAddress(
              widget.args.customerId, savedAddr.id);
        }
      }

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
