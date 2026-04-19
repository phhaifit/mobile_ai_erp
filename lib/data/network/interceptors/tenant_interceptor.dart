import 'package:dio/dio.dart';

class TenantInterceptor extends Interceptor {
  final String tenantId;

  TenantInterceptor(this.tenantId);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Tenant-Id'] = tenantId;
    super.onRequest(options, handler);
  }
}