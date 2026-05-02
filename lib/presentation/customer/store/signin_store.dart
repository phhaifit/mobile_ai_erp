import 'dart:developer';

import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:mobile_ai_erp/data/model/customer_auth/customer_auth_models.dart';
import 'package:mobile_ai_erp/presentation/customer/store/auth_store.dart';
import 'package:mobile_ai_erp/utils/oauth2_utils.dart';
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
  bool isGoogleOAuthLoading = false;

  @observable
  bool isMagicLinkLoading = false;

  @observable
  bool isMagicLinkSent = false;

  @observable
  String? magicLinkEmail;

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
    bool result = false;
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
      result = true;
    } catch (e) {
      log("SignIn error: $e");
      errorMessage = _parseErrorMessage(e.toString());
    } finally {
      isLoading = false;
    }
    return result;
  }

  /// Sign in with email and password
  @action
  Future<bool> signInWithGoogle() async {
    bool result = false;
    try {
      isGoogleOAuthLoading = true;
      errorMessage = null;
      successMessage = null;

      final (callbackUrlScheme, redirectUri) = OAuth2Utils.getRedirectUri();
      final uri = await _authRepository.getGoogleOAuthUri(redirectUri);
      final resultUriStr = await FlutterWebAuth2.authenticate(url: uri.toString(), callbackUrlScheme: callbackUrlScheme, options: const FlutterWebAuth2Options(useWebview: false));
      final resultUri = Uri.parse(resultUriStr);
      final error = resultUri.queryParameters['reason']?.toString();
      if (error != null) {
        throw error;
      }
      await _customerAuthStore.setTokenPair(TokenResponseDto.fromJson(resultUri.queryParameters).toTokenPair(), false);

      successMessage = 'Signed in successfully!';
      result = true;
    } catch (e) {
      log("SignIn error: $e");
      errorMessage = _parseErrorMessage(e.toString());
    } finally {
      isGoogleOAuthLoading = false;
    }
    return result;
  }

  /// Request magic link for passwordless sign in
  @action
  Future<bool> requestMagicLink({
    required String email,
  }) async {
    bool result = false;
    try {
      isMagicLinkLoading = true;
      errorMessage = null;
      successMessage = null;

      // Call repository to request magic link
      await _authRepository.requestMagicLink(email: email);

      // Store email and mark as sent
      magicLinkEmail = email;
      isMagicLinkSent = true;
      successMessage = 'Magic link sent successfully!';
      result = true;
    } catch (e) {
      log("RequestMagicLink error: $e");
      errorMessage = _parseErrorMessage(e.toString());
    } finally {
      isMagicLinkLoading = false;
    }
    return result;
  }

  /// Confirm magic link and sign in
  @action
  Future<bool> confirmMagicLink({
    required String token,
  }) async {
    bool result = false;
    try {
      isMagicLinkLoading = true;
      errorMessage = null;

      // Call repository to confirm magic link
      final tokenResponse = await _authRepository.confirmMagicLink(token: token);

      // Store the token pair
      await _customerAuthStore.setTokenPair(tokenResponse.toTokenPair(), false);

      isMagicLinkSent = false;
      successMessage = 'Signed in successfully!';
      result = true;
    } catch (e) {
      log("ConfirmMagicLink error: $e");
      errorMessage = _parseErrorMessage(e.toString());
    } finally {
      isMagicLinkLoading = false;
    }
    return result;
  }

  /// Reset magic link state
  @action
  void resetMagicLink() {
    isMagicLinkSent = false;
    magicLinkEmail = null;
    errorMessage = null;
    successMessage = null;
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
