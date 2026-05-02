import '../../../../domain/entity/storefront_address/storefront_address.dart';

class AddressMockDataSource {
  final List<StorefrontAddress> _mockAddresses = [
    StorefrontAddress(
      id: 'addr_1',
      address: '227 Nguyen Van Cu',
      type: 'home',
      province: 'Ho Chi Minh',
      district: 'District 1',
      ward: 'Ward 1',
      isDefault: true,
    ),
    StorefrontAddress(
      id: 'addr_2',
      address: '123 Le Loi, District 1',
      type: 'work',
      province: 'Ho Chi Minh',
      district: 'District 1',
      ward: 'Ward 2',
      isDefault: false,
    ),
  ];

  Future<List<StorefrontAddress>> getAddresses() async {
    await Future.delayed(
        const Duration(milliseconds: 200)); // Simulate network delay
    return _mockAddresses;
  }

  Future<void> addAddress(StorefrontAddress address) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockAddresses.add(address);
  }

  Future<void> updateAddress(StorefrontAddress updatedAddress) async {
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
