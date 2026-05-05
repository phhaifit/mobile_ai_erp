import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';

import 'package:mobile_ai_erp/di/service_locator.dart';

class TenantInterceptor extends Interceptor {
  static const String _placeholderTenantId =
      '00000000-0000-0000-0000-000000000000';

  final String tenantId;
  final SharedPreferenceHelper _sharedPreferenceHelper = getIt<SharedPreferenceHelper>();

  TenantInterceptor(this.tenantId) {
    if (tenantId.isEmpty || tenantId == _placeholderTenantId) {
    // 1. Just read the property directly (no parentheses, no callbacks!)
    final storedTenantId = _sharedPreferenceHelper.tenantId;

    // 2. Check the value synchronously
    if (storedTenantId != null && storedTenantId.isNotEmpty) {
      developer.log('TenantInterceptor: Using tenant ID from preferences: $storedTenantId');
    } else {
      developer.log('TenantInterceptor: No tenant ID found in preferences, using placeholder');
    }
    } else {
      developer.log('TenantInterceptor: Using tenant ID from constructor: $tenantId');
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
