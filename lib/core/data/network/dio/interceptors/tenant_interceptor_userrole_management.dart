import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TenantInterceptorUserRoleMananagement extends Interceptor {
  final AsyncValueGetter<String?> tenantId;

  TenantInterceptorUserRoleMananagement({
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
