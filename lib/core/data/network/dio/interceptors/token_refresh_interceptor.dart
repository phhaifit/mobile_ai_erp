import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class TokenRefreshInterceptor extends Interceptor {
  final AsyncValueGetter<String?> accessToken;
  final AsyncValueGetter<String?> getRefreshToken;
  final AsyncValueSetter<(String?, String?)> saveAuthToken;
  final AsyncValueGetter<String?> tenantId;
  final AsyncValueGetter<(String?, String?)> getNewTokens;
  final DioClient dioClient; // Separate dio instance for refresh calls to avoid infinite loops

  TokenRefreshInterceptor({
    required this.accessToken,
    required this.getRefreshToken,
    required this.saveAuthToken,
    required this.getNewTokens,
    required this.tenantId,
    required this.dioClient,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try {
        // Try to refresh the token
        final (newAccessToken, newRefreshToken) = await getNewTokens();
        if (newAccessToken != null) {
          // Update stored tokens
          await saveAuthToken((newAccessToken, newRefreshToken));

          // Retry the original request with new token
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final tenant = await tenantId();
          if (tenant != null) {
            err.requestOptions.headers['X-Tenant-Id'] = tenant;
          }

          // Retry the request
          final response = await dioClient.dio.request(
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

        // failed to refresh, remove all tokens
        // await saveAuthToken((null, null));
      } catch (e) {
        // Refresh failed, let the error propagate
        debugPrint('Token refresh failed: $e');
      }
    }

    super.onError(err, handler);
  }
}