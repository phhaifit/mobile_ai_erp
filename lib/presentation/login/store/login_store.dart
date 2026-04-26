import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/core/stores/form/form_store.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/customer_forgot_password_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/customer_login_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/customer_register_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'dart:convert';

part 'login_store.g.dart';

class LoginStore = _LoginStore with _$LoginStore;

abstract class _LoginStore with Store {
  // constructor:---------------------------------------------------------------
  _LoginStore(
    this._isLoggedInUseCase,
    this._saveLoginStatusUseCase,
    this._customerLoginUseCase,
    this._customerRegisterUseCase,
    this._customerForgotPasswordUseCase,
    this._sharedPreferenceHelper,
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
  final CustomerLoginUseCase _customerLoginUseCase;
  final CustomerRegisterUseCase _customerRegisterUseCase;
  final CustomerForgotPasswordUseCase _customerForgotPasswordUseCase;
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

  // empty responses:-----------------------------------------------------------
  static ObservableFuture<Map<String, dynamic>?> emptyLoginResponse =
      ObservableFuture.value(null);

  static ObservableFuture<Map<String, dynamic>?> emptyRegisterResponse =
      ObservableFuture.value(null);

  static ObservableFuture<void> emptyForgotPasswordResponse =
      ObservableFuture.value(null);

  // store variables:-----------------------------------------------------------
  bool isLoggedIn = false;

  @observable
  bool success = false;

  @observable
  ObservableFuture<Map<String, dynamic>?> loginFuture = emptyLoginResponse;

  @observable
  ObservableFuture<Map<String, dynamic>?> registerFuture = emptyRegisterResponse;

  @observable
  ObservableFuture<void> forgotPasswordFuture = emptyForgotPasswordResponse;

  @computed
  bool get isLoading => loginFuture.status == FutureStatus.pending ||
                        registerFuture.status == FutureStatus.pending ||
                        forgotPasswordFuture.status == FutureStatus.pending;

  // actions:-------------------------------------------------------------------
  @action
  Future login(String email, String password) async {
    print('🔵 [LoginStore.login] Starting login for email: $email');
    final CustomerLoginParams loginParams =
        CustomerLoginParams(email: email, password: password);
    final future = _customerLoginUseCase.call(params: loginParams);
    loginFuture = ObservableFuture(future);

    await future.then((value) async {
      if (value != null && value['accessToken'] != null) {
        print('✅ [LoginStore.login] Login successful, got accessToken');
        final accessToken = value['accessToken'];
        
        // Save the auth token
        await _sharedPreferenceHelper.saveAuthToken(accessToken);
        print('✅ [LoginStore.login] Access token saved to SharedPreferences');
        
        // Extract customer ID from JWT token
        final customerId = _extractCustomerIdFromJwt(accessToken);
        if (customerId != null && customerId.isNotEmpty) {
          print('🔑 [LoginStore.login] Extracted customer ID from JWT: $customerId');
          await _sharedPreferenceHelper.saveCustomerId(customerId);
          print('✅ [LoginStore.login] Customer ID saved to SharedPreferences');
        } else {
          print('⚠️ [LoginStore.login] Failed to extract customer ID from JWT');
        }
        
        await _saveLoginStatusUseCase.call(params: true);
        this.isLoggedIn = true;
        this.success = true;
        print('✅ [LoginStore.login] Login completed successfully');
      }
    }).catchError((e) {
      print('❌ [LoginStore.login] Login error: $e');
      this.isLoggedIn = false;
      this.success = false;
      errorStore.errorMessage = _parseError(e);
      throw e;
    });
  }

  /// Extract customer ID from JWT token
  /// JWT format: header.payload.signature
  /// Payload contains: {"sub": "customer-id", "email": "...", "tid": "...", ...}
  String? _extractCustomerIdFromJwt(String token) {
    try {
      print('🔵 [LoginStore._extractCustomerIdFromJwt] Extracting customer ID from JWT');
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ [LoginStore._extractCustomerIdFromJwt] Invalid JWT format (not 3 parts)');
        return null;
      }

      // Decode the payload (second part)
      String payload = parts[1];
      
      // Add padding if needed
      final padLength = 4 - (payload.length % 4);
      if (padLength != 4) {
        payload += '=' * padLength;
      }

      final decodedBytes = base64.decode(payload);
      final decodedString = utf8.decode(decodedBytes);
      final jsonPayload = jsonDecode(decodedString) as Map<String, dynamic>;

      print('📦 [LoginStore._extractCustomerIdFromJwt] Decoded JWT payload: $jsonPayload');

      // Extract the 'sub' claim which contains the customer ID
      final customerId = jsonPayload['sub'] as String?;
      
      if (customerId != null && customerId.isNotEmpty) {
        print('✅ [LoginStore._extractCustomerIdFromJwt] Found customer ID: $customerId');
        return customerId;
      } else {
        print('⚠️ [LoginStore._extractCustomerIdFromJwt] "sub" claim not found in JWT payload');
        return null;
      }
    } catch (e) {
      print('❌ [LoginStore._extractCustomerIdFromJwt] Error decoding JWT: $e');
      return null;
    }
  }

  @action
  Future register(String firstName, String lastName, String email, String password) async {
    final name = '$firstName $lastName'.trim();
    final CustomerRegisterParams registerParams =
        CustomerRegisterParams(
          name: name,
          email: email,
          password: password,
        );
    final future = _customerRegisterUseCase.call(params: registerParams);
    registerFuture = ObservableFuture(future);

    await future.then((value) async {
      if (value != null) {
        // Handle registration success, perhaps auto login or show message
        this.success = true;
      }
    }).catchError((e) {
      this.success = false;
      errorStore.errorMessage = _parseError(e);
      throw e;
    });
  }

  @action
  Future forgotPassword(String email) async {
    final CustomerForgotPasswordParams forgotParams =
        CustomerForgotPasswordParams(email: email);
    final future = _customerForgotPasswordUseCase.call(params: forgotParams);
    forgotPasswordFuture = ObservableFuture(future);

    await future.then((value) {
      this.success = true;
    }).catchError((e) {
      this.success = false;
      errorStore.errorMessage = _parseError(e);
      throw e;
    });
  }

  logout() async {
    print('🔵 [LoginStore.logout] Starting logout');
    this.isLoggedIn = false;
    await _sharedPreferenceHelper.removeAuthToken();
    await _sharedPreferenceHelper.removeCustomerId();
    await _saveLoginStatusUseCase.call(params: false);
    print('✅ [LoginStore.logout] Logout completed, tokens and customer ID cleared');
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
