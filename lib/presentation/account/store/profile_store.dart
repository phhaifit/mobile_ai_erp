import 'package:mobx/mobx.dart';
import '../../../../domain/entity/customer/customer.dart';
import '../../../../domain/repository/account/customer_repository.dart';

part 'profile_store.g.dart';

class ProfileStore = _ProfileStore with _$ProfileStore;

abstract class _ProfileStore with Store {
  final AccountCustomerRepository _repository;

  _ProfileStore(this._repository);

  @observable
  Customer? customer;

  @observable
  bool isLoading = false;

  @computed
  String get userName => customer?.fullName ?? '';

  @computed
  String get userEmail => customer?.email ?? '';

  @computed
  String get userPhone => customer?.phone ?? '';

  @computed
  int get loyaltyPoints => 1250; // TODO: Load from API

  @action
  Future<void> fetchProfile() async {
    isLoading = true;
    customer = await _repository.getProfile();
    isLoading = false;
  }

  @action
  Future<void> updateProfile(Map<String, dynamic> data) async {
    isLoading = true;
    customer = await _repository.updateProfile(data);
    isLoading = false;
  }
}
