import 'package:mobile_ai_erp/constants/env.dart';
import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/core/stores/form/form_store.dart';
import 'package:mobile_ai_erp/domain/usecase/auth/create_tenant_usecase.dart';
import 'package:mobx/mobx.dart';
import 'dart:developer' as developer;

import '../../../domain/entity/user/user.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/repository/user/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

part 'login_store.g.dart';

enum OAuthProvider { google, github }

// ignore: library_private_types_in_public_api
class LoginStore = _LoginStore with _$LoginStore;

abstract class _LoginStore with Store {
  // constructor:---------------------------------------------------------------
  _LoginStore(
    this._createTenantUseCase,
    this._authRepository,
    this._sharedPreferenceHelper,
    this.formErrorStore,
    this.errorStore,
  ) {
    // setting up disposers
    _setupDisposers();
    isLoggedIn = _sharedPreferenceHelper.isLoggedIn;
  }

  // use cases:-----------------------------------------------------------------
  final CreateTenantUseCase _createTenantUseCase;

  // repositories:---------------------------------------------------------------
  final AuthRepository _authRepository;
  final SharedPreferenceHelper _sharedPreferenceHelper;

  // stores:--------------------------------------------------------------------
  // for handling form errors
  final FormErrorStore formErrorStore;

  // store for handling error messages
  final ErrorStore errorStore;

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _setupDisposers() {
    _disposers = [reaction((_) => success, (_) => success = false, delay: 200)];
  }

  // store variables:-----------------------------------------------------------
  @observable
  bool isLoggedIn = false;

  @observable
  bool success = false;

  @observable
  AuthResponseUser? currentUser;

  @observable
  String? currentTenantId;

  @observable
  bool needsOnboarding = false;

  @observable
  String? errorMessage;

  @observable
  bool isLoading = false;

  @action
  Future<void> createTenant(String name, String subdomain) async {
    try {
      errorMessage = null;
      final result = await _createTenantUseCase.call(
        params: CreateTenantParams(name: name, subdomain: subdomain),
      );
      currentTenantId = result['id'] ?? result['tenantId'];
      if (currentTenantId != null) {
        await _sharedPreferenceHelper.saveTenantId(currentTenantId!);
      }
      needsOnboarding = false;
      success = true;
    } catch (e) {
      errorMessage = e.toString();
      rethrow;
    }
  }

  @action
  Future<void> logout() async {
    try {
      final accessToken = await _sharedPreferenceHelper.accessToken;
      if (accessToken != null &&
          currentUser != null &&
          currentTenantId != null) {
        await _authRepository.signOut(accessToken, currentTenantId!);
      }
    } catch (e) {
      // Sign out should not fail the operation
      developer.log('Sign out error: $e');
    } finally {
      // Clear local state
      await _clearSession();
    }
  }

  @action
  Future<bool> validateStoredSession() async {
    // Dev-only fallback for local testing with --dart-define-from-file=.env
    // This does not affect normal login flow when env values are absent
    const envAccessToken = String.fromEnvironment('ACCESS_TOKEN');
    const envRefreshToken = String.fromEnvironment('REFRESH_TOKEN');
    const envTenantId = String.fromEnvironment('TENANT_ID');

    if (envAccessToken.isNotEmpty && envTenantId.isNotEmpty) {
      await _sharedPreferenceHelper.saveAuthToken(
        accessToken: envAccessToken,
        refreshToken: envRefreshToken,
      );
      await _sharedPreferenceHelper.saveTenantId(envTenantId);

      currentTenantId = envTenantId;
      needsOnboarding = false;
      isLoggedIn = true;
      errorMessage = null;
      return true;
    }

    final accessToken = await _sharedPreferenceHelper.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      await _clearSession();
      return false;
    }

    try {
      final authStatusResponse = await _authRepository.getAuthStatus(
        accessToken,
      );
      if (!authStatusResponse.hasTenant ||
          authStatusResponse.user?.tenantId == null) {
        await _clearSession();
        return false;
      }

      currentUser = authStatusResponse.user;
      currentTenantId = authStatusResponse.user!.tenantId;
      needsOnboarding = false;
      isLoggedIn = true;

      if (currentTenantId != null) {
        await _sharedPreferenceHelper.saveTenantId(currentTenantId!);
      }

      return true;
    } catch (e) {
      await _clearSession();
      return false;
    }
  }

  Future<void> _clearSession() async {
    currentUser = null;
    currentTenantId = null;
    needsOnboarding = false;
    success = false;
    errorMessage = null;
    isLoggedIn = false;
    await _sharedPreferenceHelper.removeTenantId();
    await _sharedPreferenceHelper.removeAuthToken();
  }

  @action
  Future<void> authenticate(OAuthProvider provider) async {
    final (callbackUrlScheme, redirectUri) = _getRedirectUri();
    final (codeChallenge, codeVerifier) = _generateCodeChallenge();
    final authProviderId = provider.name;
    final state = _randomState(32);
    final stackAuthUrl = Uri.https(
      Endpoints.stackAuthHost,
      "${Endpoints.stackAuthAuthenticate}/$authProviderId",
      {
        'client_id': Env.stackAuthClientId,
        'client_secret': Env.stackAuthClientSecret,
        'redirect_uri': redirectUri,
        'scope': 'legacy',
        'grant_type': 'authorization_code',
        'response_type': 'code',
        'code_challenge_method': "S256",
        'code_challenge': codeChallenge,
        'state': state,
      },
    );
    final resultUriStr = await FlutterWebAuth2.authenticate(
      url: stackAuthUrl.toString(),
      callbackUrlScheme: callbackUrlScheme,
      options: const FlutterWebAuth2Options(useWebview: false),
    );
    final resultUri = Uri.parse(resultUriStr);

    if (state != (resultUri.queryParameters['state'] ?? '')) {
      throw Exception('invalid state received back');
    }
    final authorizationCode = resultUri.queryParameters['code'] ?? '';
    final tokens = await _authRepository.getAccessToken(
      authorizationCode,
      codeVerifier,
      redirectUri,
    );

    final authStatusResponse = await _authRepository.getAuthStatus(
      tokens.accessToken,
    );
    bool needsOnboarding = false;
    if (!authStatusResponse.hasTenant) {
      needsOnboarding = true;
    }
    currentUser = authStatusResponse.user;
    currentTenantId = authStatusResponse.user?.tenantId;
    if (currentTenantId != null) {
      await _sharedPreferenceHelper.saveTenantId(currentTenantId!);
    }

    this.needsOnboarding = needsOnboarding;
    await _sharedPreferenceHelper.saveAuthToken(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    isLoggedIn = true;
  }

  (String, String) _getRedirectUri() {
    if (kIsWeb) {
      final callbackUri = Uri(
        scheme: Uri.base.scheme,
        host: Uri.base.host,
        port: Uri.base.port,
        path: '/auth.html',
      );
      return (Uri.base.scheme, callbackUri.toString());
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      // TODO: dynamic port
      return ('http://localhost:13123', 'http://localhost:13123/');
    } else if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return ('mobile-ai-erp', 'mobile-ai-erp://');
    }
    throw UnimplementedError();
  }

  (String, String) _generateCodeChallenge() {
    const codeChallenge = "xf6HY7PIgoaCf_eMniSt-45brYE2J_05C9BnfIbueik";
    const codeVerifier = "W2LPAD4M4ES-3wBjzU6J5ApykmuxQy5VTs3oSmtboDM";
    return (codeChallenge, codeVerifier);
  }

  String _randomState(int len) {
    var r = Random();
    return String.fromCharCodes(
      List.generate(len, (index) => r.nextInt(33) + 89),
    );
  }

  // general methods:-----------------------------------------------------------
  String _parseError(dynamic error) {
    // Handle DioError specifically
    if (error is DioError) {
      if (error.response != null) {
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        switch (statusCode) {
          case 400:
            // Bad request - likely validation error
            if (data != null && data['message'] != null) {
              final message = data['message'];
              if (message is String) {
                if (message.contains('email') && message.contains('already')) {
                  return 'This email is already registered';
                }
                if (message.contains('password')) {
                  return 'Invalid password format';
                }
                if (message.contains('email')) {
                  return 'Invalid email format';
                }
                return message;
              }
              if (message is List && message.isNotEmpty) {
                return message.first.toString();
              }
            }
            return 'Invalid request. Please check your information.';
          case 401:
            // Unauthorized - wrong credentials
            return 'Invalid email or password';
          case 403:
            // Forbidden
            return 'Access denied';
          case 404:
            // Not found
            return 'Service not found. Please try again later.';
          case 409:
            // Conflict - user already exists
            return 'Account already exists with this email';
          case 422:
            // Unprocessable entity - validation errors
            if (data != null && data['message'] != null) {
              final message = data['message'];
              if (message is List && message.isNotEmpty) {
                return message.first.toString();
              }
              return message.toString();
            }
            return 'Please check your information and try again.';
          case 429:
            // Too many requests
            return 'Too many attempts. Please try again later.';
          case 500:
          case 502:
          case 503:
          case 504:
            // Server errors
            return 'Server error. Please try again later.';
          default:
            return 'Something went wrong. Please try again.';
        }
      } else {
        // Network error
        if (error.type == DioErrorType.connectionTimeout ||
            error.type == DioErrorType.receiveTimeout ||
            error.type == DioErrorType.sendTimeout) {
          return 'Connection timeout. Please check your internet connection.';
        }
        if (error.type == DioErrorType.connectionError) {
          return 'No internet connection. Please check your network.';
        }
        return 'Network error. Please check your connection.';
      }
    }

    // Handle other types of errors
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socket') || errorString.contains('network')) {
      return 'Network connection error. Please check your internet.';
    }
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    // Default fallback
    return 'Something unexpected happened. Please try again.';
  }

  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
