import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class TenantInterceptor extends Interceptor {
  static const String _placeholderTenantId =
      '00000000-0000-0000-0000-000000000000';

  final String tenantId;

  TenantInterceptor(this.tenantId) {
    if (tenantId.isEmpty || tenantId == _placeholderTenantId) {
      developer.log(
        'TenantInterceptor initialised with placeholder tenant id. '
        'Pass a real tenant via --dart-define=TENANT_ID=<uuid> '
        'or ERP API calls will fail with 401/403.',
        name: 'TenantInterceptor',
      );
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (tenantId.isNotEmpty) {
      options.headers.putIfAbsent('X-Tenant-Id', () => tenantId);
    }
    super.onRequest(options, handler);
  }
}
