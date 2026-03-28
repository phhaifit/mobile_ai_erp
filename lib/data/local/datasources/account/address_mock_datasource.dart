import '../../../../domain/entity/address/address.dart';

class AddressMockDataSource {
  final List<Address> _mockAddresses = [
    Address(
      id: 'addr_1',
      fullName: 'Khang Huynh',
      phone: '0901234567',
      street: '227 Nguyen Van Cu',
      city: 'Ho Chi Minh City',
      isDefault: true,
    ),
    Address(
      id: 'addr_2',
      fullName: 'Khang Huynh 123',
      phone: '0901234567',
      street: '123 Le Loi, District 1',
      city: 'Ho Chi Minh City',
      isDefault: false,
    ),
  ];

  Future<List<Address>> getAddresses() async {
    await Future.delayed(
        const Duration(milliseconds: 200)); // Simulate network delay
    return _mockAddresses;
  }

  Future<void> addAddress(Address address) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockAddresses.add(address);
  }

  Future<void> updateAddress(Address updatedAddress) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockAddresses.indexWhere((a) => a.id == updatedAddress.id);
    if (index != -1) {
      _mockAddresses[index] = updatedAddress;
    }
  }

  Future<void> setDefault(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i < _mockAddresses.length; i++) {
      _mockAddresses[i] =
          _mockAddresses[i].copyWith(isDefault: _mockAddresses[i].id == id);
    }
  }

  Future<void> deleteAddress(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockAddresses.removeWhere((a) => a.id == id);
  }
}
