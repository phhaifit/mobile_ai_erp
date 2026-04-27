import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/configs/dio_configs.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/tenant_header_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/token_refresh_interceptor.dart';
import 'package:mobile_ai_erp/data/network/apis/posts/post_api.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/data/network/interceptors/error_interceptor.dart';
import 'package:mobile_ai_erp/data/network/rest_client.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:event_bus/event_bus.dart';

import '../../../di/service_locator.dart';

class NetworkModule {
  static Future<void> configureNetworkModuleInjection() async {
    // event bus:---------------------------------------------------------------
    getIt.registerSingleton<EventBus>(EventBus());

    // interceptors:------------------------------------------------------------
    getIt.registerSingleton<LoggingInterceptor>(LoggingInterceptor());
    getIt.registerSingleton<ErrorInterceptor>(ErrorInterceptor(getIt()));
    getIt.registerSingleton<AuthInterceptor>(
      AuthInterceptor(
        accessToken: () async => await getIt<SharedPreferenceHelper>().accessToken,
      ),
    );
    getIt.registerSingleton<TenantHeaderInterceptor>(
      TenantHeaderInterceptor(
        tenantId: () async => await getIt<SharedPreferenceHelper>().tenantId,
      ),
    );
    getIt.registerSingleton<TokenRefreshInterceptor>(
      TokenRefreshInterceptor(
        accessToken: () async => await getIt<SharedPreferenceHelper>().accessToken,
        getRefreshToken: () async => await getIt<SharedPreferenceHelper>().refreshToken,
        saveAuthToken: (tokens) async => await getIt<SharedPreferenceHelper>().saveAuthToken(accessToken: tokens.$1, refreshToken: tokens.$2),
        tenantId: () async => await getIt<SharedPreferenceHelper>().tenantId,
        dio: Dio(BaseOptions(baseUrl: Endpoints.baseUrl)), // Separate Dio with same baseUrl
      ),
    );

    // rest client:-------------------------------------------------------------
    getIt.registerSingleton(RestClient());

    // dio:---------------------------------------------------------------------
    getIt.registerSingleton<DioConfigs>(
      const DioConfigs(
        baseUrl: Endpoints.baseUrl,
        connectionTimeout: Endpoints.connectionTimeout,
        receiveTimeout:Endpoints.receiveTimeout,
      ),
    );
    getIt.registerSingleton<DioClient>(
      DioClient(dioConfigs: getIt())
        ..addInterceptors(
          [
            getIt<TokenRefreshInterceptor>(),
            getIt<TenantHeaderInterceptor>(),
            getIt<AuthInterceptor>(),
            getIt<ErrorInterceptor>(),
            getIt<LoggingInterceptor>(),
          ],
        ),
    );

    // api's:-------------------------------------------------------------------
    getIt.registerSingleton(PostApi(getIt<DioClient>(), getIt<RestClient>()));
  }
}
