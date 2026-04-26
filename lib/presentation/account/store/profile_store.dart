import 'package:mobx/mobx.dart';
import '../../../../domain/entity/customer/customer.dart';
import '../../../../domain/usecase/customer/get_profile_usecase.dart';
import '../../../../domain/usecase/customer/update_profile_usecase.dart';

part 'profile_store.g.dart';

class ProfileStore = _ProfileStore with _$ProfileStore;

abstract class _ProfileStore with Store {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  _ProfileStore(this._getProfileUseCase, this._updateProfileUseCase);

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

  // Set to 0 because the backend schema.prisma does not support loyalty yet
  @computed
  int get loyaltyPoints => 0; 

  // 🚀 RESTORED: The missing fetchProfile method!
  @action
  Future<void> fetchProfile() async {
    try {
      print('🔵 [ProfileStore.fetchProfile] Starting profile fetch');
      isLoading = true;
      
      // Call the Use Case (adjust params if your UseCase requires a specific empty parameter)
      customer = await _getProfileUseCase.call();
      
      print('✅ [ProfileStore.fetchProfile] Success: ${customer?.name}');
    } catch (e) {
      print('❌ [ProfileStore.fetchProfile] Error: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> updateProfile({required String name, required String phone}) async {
    try {
      isLoading = true;
      final updatedCustomer = await _updateProfileUseCase.call(
        params: {
          'name': name,
          'phone': phone,
        },
      );
      customer = updatedCustomer;
      return true;
    } catch (e) {
      print('❌ [ProfileStore.updateProfile] Error: $e');
      return false;
    } finally {
      isLoading = false;
    }
  }
}