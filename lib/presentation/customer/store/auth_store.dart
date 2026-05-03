import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/data/model/customer_auth/customer_auth_models.dart';
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

  // Observable State
  @observable
  GetCustomerProfileDto? currentCustomer;

  @action
  Future<void> setTokenPair(TokenPair tokenPair) async {
    try {
      await _sharedPreferenceHelper.saveTokenPair(tokenPair);
      currentCustomer = await _customerAuthRepository.getCurrentCustomer();
      await _sharedPreferenceHelper.saveCustomerId(currentCustomer!.id);

      isLoggedIn = true;
    } catch (_) {
      await _clearSession();
      rethrow;
    }
  }

  @action
  Future<bool> validateStoredSession() async {
    try {
      currentCustomer = await _customerAuthRepository.getCurrentCustomer();
      await _sharedPreferenceHelper.saveCustomerId(currentCustomer!.id);
      isLoggedIn = true;
      return true;
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
      await _clearSession();
    }
  }

  Future<void> _clearSession() async {
    await _sharedPreferenceHelper.removeCustomerAuth();
    isLoggedIn = false;
    currentCustomer = null;
  }
}