import 'package:flutter/material.dart';
import '../../../../domain/entity/storefront_address/storefront_address.dart';
import '../../../../di/service_locator.dart';
import '../store/address_store.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final AddressStore _addressStore = getIt<AddressStore>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  bool _isDefault = false;
  bool _isLoading = false;
  bool _isInit = false;

  StorefrontAddress? _existingAddress;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is StorefrontAddress) {
        _existingAddress = args;
      }

      _nameController = TextEditingController(text: _existingAddress?.address ?? '');
      _phoneController = TextEditingController(text: _existingAddress?.type ?? '');
      _streetController = TextEditingController(text: _existingAddress?.district ?? '');
      _cityController = TextEditingController(text: _existingAddress?.province ?? '');
      // If editing, use the existing status. If creating new, check if the list is empty!
      _isDefault = _existingAddress?.isDefault ?? _addressStore.addresses.isEmpty;
      
      _isInit = true; 
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final newFullName = _nameController.text.trim();
        final newStreet = _streetController.text.trim();
        final newCity = _cityController.text.trim();
        final newPhone = _phoneController.text.trim();

        // Duplicate Check: Prevent adding/updating to an address that already exists (except itself when editing)
        final isDuplicate = _addressStore.addresses.any((existing) => 
            existing.address.toLowerCase() == newFullName.toLowerCase() &&
            existing.id != _existingAddress?.id && 
            (existing.district?.toLowerCase() ?? '').startsWith(newStreet.toLowerCase()) &&
            (existing.province?.toLowerCase() ?? '').startsWith(newCity.toLowerCase())
        );

        if (isDuplicate) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This exact address already exists on your account.')),
            );
            setState(() => _isLoading = false);
          }
          return;
        }

        final addressData = StorefrontAddress(
          id: _existingAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
          address: _nameController.text.trim(),
          type: newPhone,
          province: newCity,
          district: newStreet,
          isDefault: _isDefault,
        );

        if (_existingAddress == null) {
          await _addressStore.addAddress(addressData);
        } else {
          await _addressStore.updateAddress(addressData);
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save address: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existingAddress != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'New Address'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Full Name', 
                  border: OutlineInputBorder(),
                  counterText: '',
                  errorStyle: TextStyle(color: Colors.red),
                ),
                validator: (val) {
                  final text = val?.trim() ?? '';
                  if (text.isEmpty) return 'Required';
                  if (text.length < 2) return 'Name must be at least 2 characters';
                  if (text.length > 100) return 'Name cannot exceed 100 characters';
                  if (!RegExp(r"^[\p{L}\p{N}\s,-]+$", unicode: true).hasMatch(text)) {
                    return 'Name contains invalid characters or numbers';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_isLoading,
                maxLength: 15,
                decoration: const InputDecoration(
                  labelText: 'Phone Number', 
                  border: OutlineInputBorder(),
                  counterText: '',
                  errorStyle: TextStyle(color: Colors.red),
                ),
                validator: (val) {
                  final text = val?.trim() ?? '';
                  if (text.isEmpty) return 'Required';
                  if (text.length < 7) return 'Phone number too short';
                  
                  final cleanPhone = text.replaceAll(RegExp(r'[\s\-]'), '');
                  
                  if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(cleanPhone)) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _streetController,
                enabled: !_isLoading,
                maxLength: 255,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Street Address', 
                  border: OutlineInputBorder(),
                  counterText: '',
                  errorStyle: TextStyle(color: Colors.red),
                ),
                validator: (val) {
                  final text = val?.trim() ?? '';
                  if (text.isEmpty) return 'Required';
                  if (text.length < 5) return 'Address is too short to be valid';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _cityController,
                enabled: !_isLoading,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'City / Province', 
                  border: OutlineInputBorder(),
                  counterText: '',
                  errorStyle: TextStyle(color: Colors.red),
                ),
                validator: (val) {
                  final text = val?.trim() ?? '';
                  if (text.isEmpty) return 'Required';
                  if (text.length < 2) return 'City name is too short';
                  
                  if (!RegExp(r"^[\p{L}\p{N}\s,-]+$", unicode: true).hasMatch(text)) {
                    return 'City contains invalid characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                onPressed: _isLoading ? null : _saveAddress,
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Address', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}