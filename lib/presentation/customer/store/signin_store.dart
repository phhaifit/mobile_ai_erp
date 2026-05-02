import 'dart:developer';

import 'package:mobile_ai_erp/presentation/customer/store/auth_store.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/domain/repository/customer_auth_repository.dart';

part 'signin_store.g.dart';

class SignInStore = SignInStoreBase with _$SignInStore;

abstract class SignInStoreBase with Store {
  final CustomerAuthRepository _authRepository;
  final CustomerAuthStore _customerAuthStore;

  SignInStoreBase({
    required CustomerAuthRepository authRepository,
    required CustomerAuthStore customerAuthStore,
  })  : _authRepository = authRepository,
        _customerAuthStore = customerAuthStore;

  // Observable State
  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String? successMessage;

  @computed
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Sign in with email and password
  @action
  Future<bool> signIn({
    required String email,
    required String password,
    required bool remember,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      successMessage = null;

      // Call repository to sign in
      final tokenPair = await _authRepository.signIn(
        email: email,
        password: password,
      );

      // Store the token pair in the auth store
      await _customerAuthStore.setTokenPair(tokenPair, remember);

      successMessage = 'Signed in successfully!';
      isLoading = false;
      return true;
    } catch (e) {
      log("SignIn error: $e");
      errorMessage = _parseErrorMessage(e.toString());
      isLoading = false;
      return false;
    }
  }

  /// Clear error message
  @action
  void clearError() {
    errorMessage = null;
  }

  /// Clear success message
  @action
  void clearSuccess() {
    successMessage = null;
  }

  /// Reset store state
  @action
  void reset() {
    isLoading = false;
    errorMessage = null;
    successMessage = null;
  }

  /// Parse error message from exception
  String _parseErrorMessage(String errorString) {
    try {
      if (errorString.contains('401') || errorString.contains('Unauthorized')) {
        return 'Invalid email or password';
      }
      if (errorString.contains('404') || errorString.contains('Not Found')) {
        return 'Account not found';
      }
      if (errorString.contains('403') || errorString.contains('Forbidden')) {
        return 'Account access denied';
      }
      if (errorString.contains('500')) {
        return 'Server error. Please try again later';
      }
      if (errorString.contains('timeout') ||
          errorString.contains('TimeoutException')) {
        return 'Request timeout. Please check your connection';
      }
      return 'Sign in failed. Please try again';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }
}
