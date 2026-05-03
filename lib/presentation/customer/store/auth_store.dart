import 'dart:developer';

import 'package:mobile_ai_erp/data/sharedpref/customer_shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/entity/customer_auth/token_pair.dart';
import 'package:mobile_ai_erp/domain/repository/customer_auth_repository.dart';
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class CustomerAuthStore = CustomerAuthStoreBase with _$CustomerAuthStore;

abstract class CustomerAuthStoreBase with Store {
  final CustomerAuthRepository _customerAuthRepository;
  final CustomerSharedPreferenceHelper _sharedPreferenceHelper;

  CustomerAuthStoreBase({
    required CustomerSharedPreferenceHelper sharedPreferenceHelper,
    required CustomerAuthRepository customerAuthRepository,
  }) :
    _sharedPreferenceHelper = sharedPreferenceHelper,
    _customerAuthRepository = customerAuthRepository
  {
    isLoggedIn = _sharedPreferenceHelper.sessionId != null;
  }

  // Observable State
  @observable
  bool isLoggedIn = false;

  @action
  Future<void> setTokenPair(TokenPair tokenPair) async {
    await _sharedPreferenceHelper.saveTokenPair(tokenPair);
    isLoggedIn = true;
  }

  @action
  Future<bool> validateStoredSession() async {
    try {
      final isValid = await _customerAuthRepository.validateSession();
      if (!isValid) {
        await logout();
      }
      isLoggedIn = isValid;
      return isValid;
    } catch (e) {
      log("Exception when validating session $e");
      await logout();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (isLoggedIn) {
        await _customerAuthRepository.signOut();
      }
    } catch (e) {
      log("Exception when signing out in server $e");
    } finally {
      await _sharedPreferenceHelper.removeTokenPair();
      isLoggedIn = false;
    }
  }
}