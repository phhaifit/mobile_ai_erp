import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/domain/entity/address/address.dart';

class AddressesApi {
  final Dio _dio;

  AddressesApi(this._dio);

  Future<List<Address>> getAddresses() async {
    final res = await _dio.get(Endpoints.storefrontAddresses);
    final list = res.data as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map(Address.fromJson)
        .toList();
  }

  Future<Address> createAddress(Address address) async {
    final res = await _dio.post(
      Endpoints.storefrontAddresses,
      data: address.toJson(),
    );
    return Address.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Address> updateAddress(String id, Address address) async {
    final res = await _dio.patch(
      Endpoints.storefrontAddressById(id),
      data: address.toJson(),
    );
    return Address.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> setDefault(String id) async {
    await _dio.patch(Endpoints.storefrontAddressSetDefault(id));
  }

  Future<void> deleteAddress(String id) async {
    await _dio.delete(Endpoints.storefrontAddressById(id));
  }
}
