import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../di/service_locator.dart';
import '../../../../utils/routes/routes.dart';
import '../store/address_store.dart';
import '../widgets/address_card_widget.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({Key? key}) : super(key: key);

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
                onSetDefault: () => _addressStore.setDefault(address.id),
                onEdit: () {
                  // Pass the address object to the form so it knows we are editing
                  Navigator.pushNamed(context, Routes.addressForm, arguments: address);
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