import 'package:mobx/mobx.dart';
import '../../../../di/service_locator.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import '../../../../domain/entity/customer/customer.dart';
import '../../../domain/usecase/storefront_customer/get_profile_usecase.dart';
import '../../../domain/usecase/storefront_customer/update_profile_usecase.dart';


part 'profile_store.g.dart';

class ProfileStore = _ProfileStore with _$ProfileStore;

abstract class _ProfileStore with Store {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final SharedPreferenceHelper _prefs;

  _ProfileStore(this._getProfileUseCase, this._updateProfileUseCase, this._prefs);

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

  @action
  Future<void> logout() async {
    try {
      isLoading = true;
      
      // 1. Clear the local MobX state
      customer = null;

      // 2. Clear local storage
      await _prefs.removeAuthToken();
      await _prefs.removeCustomerId();
      await _prefs.saveIsLoggedIn(false);

      print('✅ [ProfileStore.logout] Successfully cleared session data.');
    } catch (e) {
      print('❌ [ProfileStore.logout] Error: $e');
    } finally {
      isLoading = false;
    }
  }
}