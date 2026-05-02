import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TenantHeaderInterceptor extends Interceptor {
  final AsyncValueGetter<String?> tenantId;
  final AsyncValueGetter<String?> subdomain;

  TenantHeaderInterceptor({
    required this.tenantId,
    required this.subdomain,
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

    final domain = await subdomain();
    if (domain != null && domain.isNotEmpty) {
      options.headers.putIfAbsent('X-Subdomain', () => domain);
    }

    super.onRequest(options, handler);
  }
}