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
}