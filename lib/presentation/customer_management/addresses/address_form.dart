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
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _countryController = TextEditingController(
    text: 'VN',
  );

  AddressType _type = AddressType.home;
  bool _isDefault = false;
  bool _isSaving = false;
  bool _isLoading = false;
  Address? _editingAddress;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.args.addressId != null;
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    await _store.loadAddresses(widget.args.customerId);
    if (widget.args.addressId != null) {
      _editingAddress = _store.activeAddresses.cast<Address?>().firstWhere(
        (a) => a?.id == widget.args.addressId,
        orElse: () => null,
      );
      if (_editingAddress != null) {
        _labelController.text = _editingAddress!.label;
        _streetController.text = _editingAddress!.street;
        _cityController.text = _editingAddress!.city;
        _districtController.text = _editingAddress!.state ?? '';
        _wardController.text = _editingAddress!.postalCode ?? '';
        _countryController.text = _editingAddress!.countryCode.isEmpty
            ? 'VN'
            : _editingAddress!.countryCode;
        _type = _editingAddress!.type;
        _isDefault = _editingAddress!.isDefault;
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.args.addressId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit address' : 'New address'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
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
                decoration: customerFormDecoration(labelText: 'Address'),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Address is required.';
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
                      decoration: customerFormDecoration(
                        labelText: 'Province / City',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Province is required.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _districtController,
                      decoration: customerFormDecoration(labelText: 'District'),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wardController,
                decoration: customerFormDecoration(
                  labelText: 'Ward (optional)',
                ),
                textCapitalization: TextCapitalization.words,
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
                label: Text(
                  _editingAddress == null ? 'Add address' : 'Save changes',
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
      final newAddress = Address(
        id: _editingAddress?.id ?? '',
        customerId: widget.args.customerId,
        label: _cityController.text.trim(),
        type: _type,
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _trimOrNull(_districtController.text),
        countryCode: '',
        postalCode: _trimOrNull(_wardController.text),
        isDefault: _isDefault,
      );

      // Perform validation before saving
      final validation = newAddress.validate();
      if (!validation.isValid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Address validation error: ${validation.errorMessage}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
        return;
      }

      // Save address (store will re-validate and refresh data)
      await _store.saveAddress(newAddress);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editingAddress == null
                ? 'Address added successfully'
                : 'Address updated successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } on CustomerValidationException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: Colors.red),
      );
    } on ArgumentError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Invalid address data'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
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