import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/core/stores/form/form_store.dart';
import 'package:mobile_ai_erp/domain/usecase/auth/create_tenant_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/auth/get_auth_status_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/auth/refresh_token_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/auth/sign_out_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:mobx/mobx.dart';

import '../../../domain/entity/user/user.dart';
import '../../../domain/usecase/user/login_usecase.dart';

part 'login_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  // constructor:---------------------------------------------------------------
  _UserStore(
    this._isLoggedInUseCase,
    this._saveLoginStatusUseCase,
    this._loginUseCase,
    this._getAuthStatusUseCase,
    this._refreshTokenUseCase,
    this._signOutUseCase,
    this._createTenantUseCase,
    this.formErrorStore,
    this.errorStore,
  ) {
    // setting up disposers
    _setupDisposers();

    // checking if user is logged in
    // _isLoggedInUseCase.call(params: null).then((value) async {
    //   isLoggedIn = value;
    // });
  }

  // use cases:-----------------------------------------------------------------
  final IsLoggedInUseCase _isLoggedInUseCase;
  final SaveLoginStatusUseCase _saveLoginStatusUseCase;
  final LoginUseCase _loginUseCase;
  final GetAuthStatusUseCase _getAuthStatusUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final SignOutUseCase _signOutUseCase;
  final CreateTenantUseCase _createTenantUseCase;

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

  // empty responses:-----------------------------------------------------------
  static ObservableFuture<User?> emptyLoginResponse =
      ObservableFuture.value(null);

  // store variables:-----------------------------------------------------------
  bool isLoggedIn = false;

  @observable
  bool success = false;

  @observable
  ObservableFuture<User?> loginFuture = emptyLoginResponse;

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

  @computed
  bool get isLoading => loginFuture.status == FutureStatus.pending;

  @computed
  bool get isAuthenticated => currentUser != null && currentTenantId != null;

  // actions:-------------------------------------------------------------------
  @action
  Future login(String email, String password) async {
    final LoginParams loginParams =
        LoginParams(username: email, password: password);
    final future = _loginUseCase.call(params: loginParams);
    loginFuture = ObservableFuture(future);

    await future.then((value) async {
      if (value != null) {
        await _saveLoginStatusUseCase.call(params: true);
        this.isLoggedIn = true;
        this.success = true;
      }
    }).catchError((e) {
      print(e);
      this.isLoggedIn = false;
      this.success = false;
      throw e;
    });
  }

  @action
  Future<void> loginWithStackAuth(String accessToken, String refreshToken) async {
    try {
      errorMessage = null;
      // Store tokens (this would be done by the OAuth callback handler)
      // For now, assume tokens are already stored

      // Check auth status
      await checkAuthStatus();
    } catch (e) {
      errorMessage = e.toString();
      throw e;
    }
  }

  @action
  Future<void> checkAuthStatus() async {
    try {
      errorMessage = null;
      final user = await _getAuthStatusUseCase.call(params: 'dummy_token'); // Token will be retrieved from storage
      currentUser = user;
      currentTenantId = user.tenantId;
      currentTenantName = user.tenantName;
      needsOnboarding = user.tenantId == null;
      isLoggedIn = true;
      success = true;
    } catch (e) {
      errorMessage = e.toString();
      isLoggedIn = false;
      success = false;
      throw e;
    }
  }

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
      throw e;
    }
  }

  @action
  Future<void> logout() async {
    try {
      if (currentUser != null && currentTenantId != null) {
        await _signOutUseCase.call(
          params: SignOutParams(
            accessToken: 'dummy_token', // Token will be retrieved from storage
            tenantId: currentTenantId!,
          ),
        );
      }
    } catch (e) {
      // Sign out should not fail the operation
      print('Sign out error: $e');
    } finally {
      // Clear local state
      currentUser = null;
      currentTenantId = null;
      currentTenantName = null;
      needsOnboarding = false;
      isLoggedIn = false;
      success = false;
      errorMessage = null;
      await _saveLoginStatusUseCase.call(params: false);
    }
  }

  // general methods:-----------------------------------------------------------
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
