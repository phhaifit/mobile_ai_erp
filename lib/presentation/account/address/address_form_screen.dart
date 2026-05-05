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

  late TextEditingController _addressController;
  late TextEditingController _provinceController;
  late TextEditingController _districtController;
  late TextEditingController _wardController;
  
  AddressType _selectedType = AddressType.home;
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

      _addressController = TextEditingController(text: _existingAddress?.address ?? '');
      _provinceController = TextEditingController(text: _existingAddress?.province ?? '');
      _districtController = TextEditingController(text: _existingAddress?.district ?? '');
      _wardController = TextEditingController(text: _existingAddress?.ward ?? '');
      
      _selectedType = _existingAddress?.type ?? AddressType.home;
      _isDefault = _existingAddress?.isDefault ?? _addressStore.addresses.isEmpty;
      
      _isInit = true; 
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final newAddress = _addressController.text.trim();
        final newProvince = _provinceController.text.trim();
        final newDistrict = _districtController.text.trim();
        final newWard = _wardController.text.trim();

        // Exact match Duplicate Check based on DB fields
        final isDuplicate = _addressStore.addresses.any((existing) => 
            existing.address.toLowerCase() == newAddress.toLowerCase() &&
            existing.id != _existingAddress?.id && 
            (existing.province?.toLowerCase() ?? '') == newProvince.toLowerCase() &&
            (existing.district?.toLowerCase() ?? '') == newDistrict.toLowerCase() &&
            (existing.ward?.toLowerCase() ?? '') == newWard.toLowerCase() &&
            existing.type == _selectedType
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
          address: newAddress,
          type: _selectedType,
          province: newProvince.isEmpty ? null : newProvince,
          district: newDistrict.isEmpty ? null : newDistrict,
          ward: newWard.isEmpty ? null : newWard,
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
              // 1. Address Type Dropdown
              DropdownButtonFormField<AddressType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Address Type',
                  border: OutlineInputBorder(),
                ),
                items: AddressType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.value.toUpperCase()), // E.g. "HOME", "OFFICE"
                  );
                }).toList(),
                onChanged: _isLoading ? null : (AddressType? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedType = newValue);
                  }
                },
              ),
              
              const SizedBox(height: 16),

              // 2. Street Address
              TextFormField(
                controller: _addressController,
                enabled: !_isLoading,
                maxLength: 500,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Street Address', 
                  border: OutlineInputBorder(),
                  counterText: '',
                  errorStyle: TextStyle(color: Colors.red),
                ),
                validator: (val) {
                  final text = val?.trim() ?? '';
                  if (text.isEmpty) return 'Required';
                  if (text.length < 5) return 'Address is too short';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 3. Province
              TextFormField(
                controller: _provinceController,
                enabled: !_isLoading,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Province / State', 
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 16),

              // 4. District
              TextFormField(
                controller: _districtController,
                enabled: !_isLoading,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'District / City', 
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 16),

              // 5. Ward
              TextFormField(
                controller: _wardController,
                enabled: !_isLoading,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Ward / Area', 
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 16),

              // 6. Set as Default Checkbox
              CheckboxListTile(
                title: const Text("Set as default address"),
                value: _isDefault,
                onChanged: _isLoading ? null : (bool? value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
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