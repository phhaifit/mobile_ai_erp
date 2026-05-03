import 'dart:convert';

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

  String? get sessionId => sharedPreference.getString(Preferences.session_id);

  Future<void> removeTokenPair() async {
    await sharedPreference.remove(Preferences.session_id);
    await removeAuthToken();
  }

  /// Clear subdomain and tenant ID data
  Future<void> clearSubdomainData() async {
    await removeSubdomain();
    await removeTenantId();
  }
}