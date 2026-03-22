import 'package:flutter/material.dart';
import '../../../../domain/entity/address/address.dart';
import '../../../../di/service_locator.dart';
import '../store/address_store.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({Key? key}) : super(key: key);

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

  Address? _existingAddress;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we passed an existing Address to edit
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Address) {
      _existingAddress = args;
    }

    // Pre-fill controllers if editing
    _nameController = TextEditingController(text: _existingAddress?.fullName ?? '');
    _phoneController = TextEditingController(text: _existingAddress?.phone ?? '');
    _streetController = TextEditingController(text: _existingAddress?.street ?? '');
    _cityController = TextEditingController(text: _existingAddress?.city ?? '');
    _isDefault = _existingAddress?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      final addressData = Address(
        // Mock a new ID if creating, otherwise keep existing ID
        id: _existingAddress?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
        fullName: _nameController.text,
        phone: _phoneController.text,
        street: _streetController.text,
        city: _cityController.text,
        isDefault: _isDefault,
      );

      if (_existingAddress == null) {
        await _addressStore.addAddress(addressData);
      } else {
        await _addressStore.updateAddress(addressData);
      }
      
      if (mounted) Navigator.pop(context); // Go back to the list
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
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Street Address', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City / Province', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Set as Default Address'),
                value: _isDefault,
                activeColor: Colors.blue,
                onChanged: (bool value) {
                  setState(() => _isDefault = value);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                onPressed: _saveAddress,
                child: const Text('Save Address', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}