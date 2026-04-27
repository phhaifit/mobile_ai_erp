import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/core/stores/form/form_store.dart';
import 'package:mobile_ai_erp/domain/usecase/auth/create_tenant_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/auth/refresh_token_usecase.dart';
import 'package:mobx/mobx.dart';

import '../../../domain/entity/user/user.dart';
import '../../../domain/usecase/user/login_usecase.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/core/data/network/constants/network_constants.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/repository/user/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

part 'login_store.g.dart';

class LoginStore = _LoginStore with _$LoginStore;

abstract class _LoginStore with Store {
  // constructor:---------------------------------------------------------------
  _LoginStore(
    this._loginUseCase,
    this._refreshTokenUseCase,
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
  final LoginUseCase _loginUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
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
    _disposers = [
      reaction((_) => success, (_) => success = false, delay: 200),
    ];
  }

  // store variables:-----------------------------------------------------------
  @observable
  bool isLoggedIn = false;

  @observable
  bool success = false;

  @observable
  User? currentUser;

  @observable
  String? currentTenantId;

  @observable
  String? currentTenantName;

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
      currentTenantId = result['tenantId'];
      currentTenantName = result['name'];
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
      if (accessToken != null && currentUser != null && currentTenantId != null) {
        await _authRepository.signOut(accessToken, currentTenantId!);
      }
    } catch (e) {
      // Sign out should not fail the operation
      debugPrint('Sign out error: $e');
    } finally {
      // Clear local state
      currentUser = null;
      currentTenantId = null;
      currentTenantName = null;
      needsOnboarding = false;
      success = false;
      errorMessage = null;
      await _sharedPreferenceHelper.removeAuthToken();
      isLoggedIn = false;
    }
  }

  @action
  Future<void> authenticate() async {
    final (callbackUrlScheme, redirectUri) = _getRedirectUri();
    final (codeChallenge, codeVerifier) = _generateCodeChallenge();
    const authProviderId = "google";
    final state = _randomState(32);
    final stackAuthUrl = Uri.https(Endpoints.stackAuthHost, "${Endpoints.stackAuthAuthenticate}/$authProviderId", {
      'client_id': NetworkConstants.stackAuthClientId,
      'client_secret': NetworkConstants.stackAuthClientSecret,
      'redirect_uri': redirectUri,
      'scope': 'legacy',
      'grant_type': 'authorization_code',
      'response_type': 'code',
      'code_challenge_method': "S256",
      'code_challenge': codeChallenge,
      'state': state,
    });
    final resultUriStr = await FlutterWebAuth2.authenticate(url: stackAuthUrl.toString(), callbackUrlScheme: callbackUrlScheme, options: const FlutterWebAuth2Options(useWebview: false));
    final resultUri = Uri.parse(resultUriStr);

    if (state != (resultUri.queryParameters['state'] ?? '')) {
      throw Exception('invalid state received back');
    }
    final authorizationCode = resultUri.queryParameters['code'] ?? '';
    final tokens = await _authRepository.getAccessToken(authorizationCode, codeVerifier, redirectUri);
    debugPrint("Access token: ${tokens.accessToken}");
    debugPrint("Refresh token: ${tokens.refreshToken}");

    final authStatusResponse = await _authRepository.getAuthStatus(tokens.accessToken);
    debugPrint(authStatusResponse.toJson().toString());
    bool needsOnboarding = false;
    if (!authStatusResponse.hasTenant) {
      needsOnboarding = true;
    }
    currentUser = authStatusResponse.user;
    currentTenantId = authStatusResponse.user?.tenantId;
    currentTenantName = authStatusResponse.user?.tenantName;
    

    this.needsOnboarding = needsOnboarding;
    await _sharedPreferenceHelper.saveAuthToken(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
    isLoggedIn = true;
  }

  (String, String) _getRedirectUri() {
    if (defaultTargetPlatform == TargetPlatform.windows ||
       defaultTargetPlatform == TargetPlatform.linux ||
       defaultTargetPlatform == TargetPlatform.macOS) {
        // TODO: dynamic port
        return ('http://localhost:13123', 'http://localhost:13123/');
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
    return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
