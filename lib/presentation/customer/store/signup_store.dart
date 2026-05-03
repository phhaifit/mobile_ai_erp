import 'dart:developer';

import 'package:mobile_ai_erp/presentation/customer/store/auth_store.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/domain/repository/customer_auth_repository.dart';

part 'signup_store.g.dart';

class SignUpStore = SignUpStoreBase with _$SignUpStore;

abstract class SignUpStoreBase with Store {
  final CustomerAuthRepository _authRepository;
  final CustomerAuthStore _customerAuthStore;

  SignUpStoreBase({
    required CustomerAuthRepository authRepository,
    required CustomerAuthStore customerAuthStore,
  }) :
    _authRepository = authRepository,
    _customerAuthStore = customerAuthStore;

  // Observable State
  @observable
  bool isLoading = false;

  @observable
  bool isEmailVerificationPending = false;

  @observable
  String? errorMessage;

  @observable
  String? successMessage;

  @observable
  String? verificationEmail;

  @observable
  bool isEmailVerified = false;

  @computed
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Sign up with email and password
  @action
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    bool result = false;
    try {
      isLoading = true;
      errorMessage = null;
      successMessage = null;

      // Call API
      final _ = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );

      // Store response
      verificationEmail = email;
      isEmailVerificationPending = true;
      successMessage = 'Sign up successful! Please verify your email.';

      result = true;
    } catch (e) {
      errorMessage = _parseErrorMessage(e.toString());
    } finally {
      isLoading = false;
    }
    return result;
  }

  /// Verify email with verification token
  @action
  Future<bool> verifyEmail({
    required String token,
  }) async {
    bool result = false;
    try {
      isLoading = true;
      errorMessage = null;

      // Call API
      final tokenResponse = await _authRepository.verifyEmail(token: token);

      await _customerAuthStore.setTokenPair(tokenResponse.toTokenPair());

      // Store customer
      isEmailVerificationPending = false;
      isEmailVerified = true;
      successMessage = 'Email verified successfully!';

      result = true;
    } catch (e) {
      errorMessage = _parseErrorMessage(e.toString());
    } finally {
      isLoading = false;
    }
    return result;
  }

  /// Clear sign up form state
  @action
  void resetSignUp() {
    errorMessage = null;
    successMessage = null;
    isLoading = false;
    isEmailVerificationPending = false;
    verificationEmail = null;
    isEmailVerified = false;
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

  /// Parse error message from exception
  String _parseErrorMessage(String exception) {
    if (exception.contains('400')) {
      return 'Invalid email or password format';
    } else if (exception.contains('409')) {
      return 'Email already registered';
    } else if (exception.contains('422')) {
      return 'Invalid input data';
    } else if (exception.contains('500')) {
      return 'Server error. Please try again later';
    } else if (exception.contains('Connection refused')) {
      return 'Cannot connect to server. Check your internet connection.';
    }
    log('Sign up failed: $exception');
    return 'Sign up failed';
  }
}
