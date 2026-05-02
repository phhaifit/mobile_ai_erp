import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/data/sharedpref/constants/preferences.dart';

class CustomerSharedPreferenceHelper extends SharedPreferenceHelper {
  CustomerSharedPreferenceHelper(super._sharedPreference) : super();

  /// Save subdomain to shared preferences
  Future<void> saveSubdomain(String subdomain) async {
    await sharedPreference.setString(Preferences.customer_subdomain, subdomain);
  }

  /// Get stored subdomain
  String? get subdomain => sharedPreference.getString(Preferences.customer_subdomain);

  /// Clear subdomain and tenant ID data
  Future<void> clearSubdomainData() async {
    await sharedPreference.remove(Preferences.customer_subdomain);
    await sharedPreference.remove(Preferences.tenant_id);
  }
}

