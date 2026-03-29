import 'package:mobx/mobx.dart';
import '../../../../domain/entity/address/address.dart';
import '../../../../domain/repository/account/address_repository.dart';

part 'address_store.g.dart';

class AddressStore = _AddressStore with _$AddressStore;

abstract class _AddressStore with Store {
  final AddressRepository _repository; // Changed type and name

  _AddressStore(this._repository); // Changed constructor

  @observable
  ObservableList<Address> addresses = ObservableList<Address>();

  @observable
  bool isLoading = false;

  @action
  Future<void> fetchAddresses() async {
    isLoading = true;
    final data = await _repository.getAddresses(); // Use _repository here
    addresses = ObservableList.of(data);
    isLoading = false;
  }

  @action
  Future<void> setDefault(String id) async {
    isLoading = true;
    await _repository.setDefault(id); // Use _repository here
    await fetchAddresses();
  }

  @action
  Future<void> addAddress(Address address) async {
    isLoading = true;
    await _repository.addAddress(address);
    await fetchAddresses(); // Refresh list
  }

  @action
  Future<void> updateAddress(Address address) async {
    isLoading = true;
    await _repository.updateAddress(address);
    await fetchAddresses(); // Refresh list
  }

  @action
  Future<void> deleteAddress(String id) async {
    isLoading = true;
    try {
      // Check if the address we are about to delete is the default one
      final addressToDeleteIndex = addresses.indexWhere((a) => a.id == id);
      final bool wasDefault = addressToDeleteIndex != -1 
          ? addresses[addressToDeleteIndex].isDefault 
          : false;

      // Perform the deletion
      await _repository.deleteAddress(id); 
      
      // Refresh the list so we have the most accurate remaining addresses
      await fetchAddresses(); 

      // The Business Rule: If we deleted the default, and there are still addresses left,
      // make the first item in the newly fetched list the new default.
      if (wasDefault && addresses.isNotEmpty) {
        await setDefault(addresses.first.id); 
      }
      
    } catch (e) {
      isLoading = false;
      rethrow; 
    }
  }
}
