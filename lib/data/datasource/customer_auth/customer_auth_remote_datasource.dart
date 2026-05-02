import 'package:mobile_ai_erp/data/model/customer_auth/customer_auth_models.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/customer_auth_api.dart';

abstract class CustomerAuthRemoteDatasource {
  Future<TokenResponseModel> signUp({
    required String email,
    required String password,
  });

  Future<CustomerModel> verifyEmail({
    required String token,
  });

  Future<SignInResponseModel> signIn({
    required String email,
    required String password,
  });

  Future<void> requestMagicLink({
    required String email,
  });

  Future<SignInResponseModel> confirmMagicLink({
    required String token,
  });

  Future<String> initiateGoogleOAuth({
    required String redirectUri,
  });

  Future<SignInResponseModel> googleOAuthCallback({
    required String authorizationCode,
  });

  Future<TokenResponseModel> refreshToken({
    required String refreshToken,
  });

  Future<void> signOut({
    required String accessToken,
  });

  Future<List<SessionModel>> listSessions({
    required String accessToken,
  });

  Future<void> revokeSession({
    required String accessToken,
    required String sessionId,
  });
}

class CustomerAuthRemoteDatasourceImpl implements CustomerAuthRemoteDatasource {
  final CustomerAuthApi _customerAuthApi;

  CustomerAuthRemoteDatasourceImpl({
    required CustomerAuthApi customerAuthApi,
  }) : _customerAuthApi = customerAuthApi;

  @override
  Future<TokenResponseModel> signUp({
    required String email,
    required String password,
  }) {
    return _customerAuthApi.signUp(email: email, password: password);
  }

  @override
  Future<CustomerModel> verifyEmail({
    required String token,
  }) {
    return _customerAuthApi.verifyEmail(token: token);
  }

  @override
  Future<SignInResponseModel> signIn({
    required String email,
    required String password,
  }) {
    return _customerAuthApi.signIn(email: email, password: password);
  }

  @override
  Future<void> requestMagicLink({
    required String email,
  }) {
    return _customerAuthApi.requestMagicLink(email: email);
  }

  @override
  Future<SignInResponseModel> confirmMagicLink({
    required String token,
  }) {
    return _customerAuthApi.confirmMagicLink(token: token);
  }

  @override
  Future<String> initiateGoogleOAuth({
    required String redirectUri,
  }) {
    return _customerAuthApi.initiateGoogleOAuth(redirectUri: redirectUri);
  }

  @override
  Future<SignInResponseModel> googleOAuthCallback({
    required String authorizationCode,
  }) {
    return _customerAuthApi.googleOAuthCallback(
      authorizationCode: authorizationCode,
    );
  }

  @override
  Future<TokenResponseModel> refreshToken({
    required String refreshToken,
  }) {
    return _customerAuthApi.refreshToken(refreshToken: refreshToken);
  }

  @override
  Future<void> signOut({
    required String accessToken,
  }) {
    return _customerAuthApi.signOut(accessToken: accessToken);
  }

  @override
  Future<List<SessionModel>> listSessions({
    required String accessToken,
  }) {
    return _customerAuthApi.listSessions(accessToken: accessToken);
  }

  @override
  Future<void> revokeSession({
    required String accessToken,
    required String sessionId,
  }) {
    return _customerAuthApi.revokeSession(
      accessToken: accessToken,
      sessionId: sessionId,
    );
  }
}
