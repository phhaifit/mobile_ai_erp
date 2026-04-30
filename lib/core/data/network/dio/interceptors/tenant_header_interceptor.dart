import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TenantHeaderInterceptor extends Interceptor {
  final AsyncValueGetter<String?> tenantId;

  TenantHeaderInterceptor({
    required this.tenantId,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tenant = await tenantId();
    if (tenant != null && tenant.isNotEmpty) {
      options.headers.putIfAbsent('X-Tenant-Id', () => tenant);
    }

    super.onRequest(options, handler);
  }
}