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
    _customerAuthRepository = customerAuthRepository {
    tokenPair = _sharedPreferenceHelper.loadTokenPair();
  }

  // Observable State
  @observable
  TokenPair? tokenPair;

  @action
  Future<void> setTokenPair(TokenPair tokenPair) async {
    await _sharedPreferenceHelper.saveTokenPair(tokenPair);
    this.tokenPair = tokenPair;
  }

  Future<void> logout() async {
    try {
      await _customerAuthRepository.signOut();
    } catch (e) {
      log("Exception when signing out in server $e");
    } finally {
      await _sharedPreferenceHelper.removeTokenPair();
      tokenPair = null;
    }
  }
}