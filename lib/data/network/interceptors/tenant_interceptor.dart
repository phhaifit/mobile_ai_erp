import 'package:dio/dio.dart';

class TenantInterceptor extends Interceptor {
  TenantInterceptor({
    required this.tenantId,
  });

  final String tenantId;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (tenantId.trim().isNotEmpty) {
      options.headers.putIfAbsent('X-Tenant-Id', () => tenantId.trim());
    }
    super.onRequest(options, handler);
  }
}
