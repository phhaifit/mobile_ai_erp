import 'dart:convert';

import 'package:mobile_ai_erp/data/sharedpref/constants/preferences.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/entity/customer_auth/token_pair.dart';

class CustomerSharedPreferenceHelper extends SharedPreferenceHelper {
  CustomerSharedPreferenceHelper(super.sharedPreference);

  TokenPair? loadTokenPair() {
    final tokenPairStr = sharedPreference.getString(Preferences.token_pair);

    if (tokenPairStr == null) {
      return null;
    }

    return TokenPair.fromJson(jsonDecode(tokenPairStr));
  }

  Future<void> saveTokenPair(TokenPair tokenPair) async {
    await saveAuthToken(
      accessToken: tokenPair.accessToken,
      refreshToken: tokenPair.refreshToken,
    );

    await sharedPreference.setString(
      Preferences.token_pair,
      jsonEncode(tokenPair.toJson()),
    );
  }

  /// Clear subdomain and tenant ID data
  Future<void> clearSubdomainData() async {
    await removeSubdomain();
    await removeTenantId();
  }
}