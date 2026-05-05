import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../di/service_locator.dart';
import '../../../../utils/routes/routes.dart';
import '../store/address_store.dart';
import '../widgets/address_card_widget.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final AddressStore _addressStore = getIt<AddressStore>();

  @override
  void initState() {
    super.initState();
    // Fetch the mock addresses when the screen loads
    _addressStore.fetchAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Book'),
        elevation: 0,
      ),
      body: Observer(
        builder: (_) {
          if (_addressStore.isLoading && _addressStore.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_addressStore.addresses.isEmpty) {
            return const Center(child: Text('No addresses found. Add one!'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _addressStore.addresses.length,
            itemBuilder: (context, index) {
              final address = _addressStore.addresses[index];
              return AddressCardWidget(
                address: address,
                onSetDefault: () async {
                  // 1. Check if the UI thinks it's loading
                  if (_addressStore.isLoading) {
                    print('🛑 BUTTON CLICKED, BUT STORE IS LOADING! Ignored.');
                    return; 
                  }

                  print('🟢 BUTTON CLICKED! Calling Store...');
                  final success = await _addressStore.setDefault(address.id);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Default address updated!' : 'Failed to update.'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                onEdit: () {
                  // Pass the address object to the form so it knows we are editing
                  Navigator.pushNamed(context, Routes.addressForm,
                      arguments: address);
                },
                onDelete: () {
                  // Show confirmation dialog before deleting
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Address'),
                        content: const Text('Are you sure you want to delete this address? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(), // Cancel
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); 
                              // Call the store using your actual _addressStore variable
                              _addressStore.deleteAddress(address.id); 
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      // Floating button to add a new address
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.addressForm),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
