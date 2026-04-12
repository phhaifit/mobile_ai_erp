import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TenantInterceptor extends Interceptor {
  final AsyncValueGetter<String?> tenantId;

  TenantInterceptor({
    required this.tenantId,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? currentTenantId = await tenantId();
    if (currentTenantId != null && currentTenantId.isNotEmpty) {
      options.headers.putIfAbsent('x-tenant-id', () => currentTenantId);
    }

    super.onRequest(options, handler);
  }
}
