import 'package:mobile_ai_erp/data/sharedpref/constants/preferences.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/entity/customer_auth/token_pair.dart';

class CustomerSharedPreferenceHelper extends SharedPreferenceHelper {
  CustomerSharedPreferenceHelper(super.sharedPreference);

  Future<void> saveTokenPair(TokenPair tokenPair) async {
    await saveAuthToken(
      accessToken: tokenPair.accessToken,
      refreshToken: tokenPair.refreshToken,
    );

    await sharedPreference.setString(
      Preferences.session_id,
      tokenPair.sessionId,
    );
  }

  Future<void> saveCustomerId(String customerId) async {
    await sharedPreference.setString(Preferences.customer_id, customerId);
  }

  String? get customerId => sharedPreference.getString(Preferences.customer_id);
  String? get sessionId => sharedPreference.getString(Preferences.session_id);

  Future<void> removeCustomerAuth() async {
    await sharedPreference.remove(Preferences.session_id);
    await sharedPreference.remove(Preferences.customer_id);
    await removeAuthToken();
  }

  /// Clear subdomain and tenant ID data
  Future<void> clearSubdomainData() async {
    await removeSubdomain();
    await removeTenantId();
  }
}