import 'package:mobx/mobx.dart';
import '../../../../domain/entity/storefront_address/storefront_address.dart';
import '../../../../domain/repository/account/address_repository.dart';

part 'address_store.g.dart';

class AddressStore = _AddressStore with _$AddressStore;

abstract class _AddressStore with Store {
  final StorefrontAddressRepository _repository; // Changed type and name

  _AddressStore(this._repository); // Changed constructor

  @observable
  ObservableList<StorefrontAddress> addresses = ObservableList<StorefrontAddress>();

  @observable
  bool isLoading = false;

  @action
  Future<void> fetchAddresses() async {
    try {
      print('🔵 [AddressStore.fetchAddresses] Starting addresses fetch');
      isLoading = true;
      
      final data = await _repository.getAddresses();
      print('✅ [AddressStore.fetchAddresses] Got ${data.length} addresses');
      
      if (data.isEmpty) {
        print('⚠️ [AddressStore.fetchAddresses] Backend endpoint missing!');
        print('⚠️ [AddressStore.fetchAddresses] See: report_missing_endpoints.md');
      }
      
      addresses = ObservableList.of(data);
      isLoading = false;
    } catch (e) {
      print('❌ [AddressStore.fetchAddresses] Error: $e');
      isLoading = false;
      // Don't rethrow - show empty list
    }
  }

  @action
  Future<bool> setDefault(String id) async {
    try {
      isLoading = true;
      
      await _repository.setDefault(id);
      
      await fetchAddresses();
      return true; // Success
    } catch (e) {
      return false; // Failed
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addAddress(StorefrontAddress address) async {
    isLoading = true;
    await _repository.addAddress(address);
    await fetchAddresses(); // Refresh list
  }

  @action

  Future<void> updateAddress(StorefrontAddress address) async {
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
