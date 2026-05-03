import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';

class TenantHeaderInterceptor extends Interceptor {
  static const String _placeholderTenantId =
      '00000000-0000-0000-0000-000000000000';

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
    if (options.uri.host == Endpoints.stackAuthHost) {
      super.onRequest(options, handler);
      return;
    }

    final tenant = await tenantId();
    if (tenant != null &&
        tenant.isNotEmpty &&
        tenant != _placeholderTenantId) {
      options.headers.putIfAbsent('X-Tenant-Id', () => tenant);
    }

    final domain = await subdomain();
    if (domain != null && domain.isNotEmpty) {
      options.headers.putIfAbsent('X-Subdomain', () => domain);
    }

    super.onRequest(options, handler);
  }
}
