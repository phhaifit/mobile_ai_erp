import 'package:mobile_ai_erp/data/sharedpref/customer_shared_preference_helper.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/domain/repository/customer_auth_repository.dart';

part 'subdomain_store.g.dart';

class SubdomainStore = SubdomainStoreBase with _$SubdomainStore;

abstract class SubdomainStoreBase with Store {
  final CustomerAuthRepository _authRepository;
  final CustomerSharedPreferenceHelper _preferences;

  SubdomainStoreBase({
    required CustomerAuthRepository authRepository,
    required CustomerSharedPreferenceHelper preferences,
  })  : _authRepository = authRepository,
        _preferences = preferences {
    subdomain = _preferences.subdomain;
    tenantId = _preferences.tenantId;
  }

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String? tenantId;

  @observable
  String? subdomain;

  @action
  Future<bool> submitSubdomain(String subdomainInput) async {
    try {
      isLoading = true;
      errorMessage = null;

      // Get tenant ID from API
      final retrievedTenantId = await _authRepository.getTenantId(subdomainInput);

      // Save to shared preferences
      await _preferences.saveTenantId(retrievedTenantId);
      await _preferences.saveSubdomain(subdomainInput);

      // Update state
      tenantId = retrievedTenantId;
      subdomain = subdomainInput;

      isLoading = false;
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = 'Invalid subdomain or server error';
      return false;
    }
  }

  @action
  Future<void> clearSubdomainData() async {
    await _preferences.clearSubdomainData();
    tenantId = null;
    subdomain = null;
    errorMessage = null;
  }

  /// Load subdomain data from preferences (useful for app initialization)
  @action
  void loadSubdomainFromPreferences() {
    tenantId = _preferences.tenantId;
    subdomain = _preferences.subdomain;
  }

  /// Validate saved subdomain by calling getTenantId
  /// Returns true if subdomain exists and is valid, false otherwise
  @action
  Future<bool> validateStoredSubdomain() async {
    final storedSubdomain = _preferences.subdomain;
    
    // If no subdomain is stored, return false
    if (storedSubdomain == null || storedSubdomain.isEmpty) {
      return false;
    }

    try {
      isLoading = true;
      errorMessage = null;

      // Try to get tenant ID for the stored subdomain
      final retrievedTenantId = await _authRepository.getTenantId(storedSubdomain);

      // If successful, update state
      tenantId = retrievedTenantId;
      subdomain = storedSubdomain;
      isLoading = false;
      return true;
    } catch (e) {
      // If validation fails, clear the stored subdomain
      await clearSubdomainData();
      isLoading = false;
      return false;
    }
  }
}
