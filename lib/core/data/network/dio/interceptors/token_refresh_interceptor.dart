import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TokenRefreshInterceptor extends Interceptor {
  final AsyncValueGetter<String?> accessToken;
  final AsyncValueGetter<String?> getRefreshToken;
  final AsyncValueSetter<(String, String)> saveAuthToken;
  final AsyncValueGetter<String?> tenantId;
  final Dio dio; // Separate dio instance for refresh calls to avoid infinite loops

  TokenRefreshInterceptor({
    required this.accessToken,
    required this.getRefreshToken,
    required this.saveAuthToken,
    required this.tenantId,
    required this.dio,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        // Try to refresh the token
        final refreshToken = await getRefreshToken();
        if (refreshToken == null) {
          return;
        }
        final newTokens = await _refreshToken(refreshToken);
        if (newTokens != null) {
          final accessTokens = newTokens['accessToken']!;
          final refreshTokens = newTokens['refreshToken'] ?? refreshToken;
          // Update stored tokens
          await saveAuthToken((accessTokens, refreshTokens));

          // Retry the original request with new token
          final newToken = await accessToken();
          if (newToken != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final tenant = await tenantId();
            if (tenant != null) {
              err.requestOptions.headers['X-Tenant-Id'] = tenant;
            }

            // Retry the request
            final response = await dio.request(
              err.requestOptions.path,
              options: Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers,
              ),
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );

            return handler.resolve(response);
          }
        }
      } catch (e) {
        // Refresh failed, let the error propagate
        debugPrint('Token refresh failed: $e');
      }
    }

    super.onError(err, handler);
  }

  Future<Map<String, String>?> _refreshToken(String refreshToken) async {
    final tenant = await tenantId();
    if (tenant == null) return null;

    try {
      final response = await dio.get(
        '/auth/refresh', // Use relative URL since baseUrl is already set
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
            'X-Tenant-Id': tenant,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return {
          'accessToken': response.data['accessToken'],
          'refreshToken': response.data['refreshToken'], // May be null if not rotated
        };
      }
    } catch (e) {
      debugPrint('Refresh token request failed: $e');
    }

    return null;
  }
}