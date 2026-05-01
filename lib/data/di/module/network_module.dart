import 'package:mobile_ai_erp/core/data/network/dio/configs/dio_configs.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/tenant_header_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/token_refresh_interceptor.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/order_api.dart';
import 'package:mobile_ai_erp/data/network/apis/posts/post_api.dart';
import 'package:mobile_ai_erp/data/network/apis/web_builder/web_builder_api.dart';
import 'package:mobile_ai_erp/data/network/apis/suppliers/supplier_api.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/data/network/constants/storefront_endpoints.dart';
import 'package:mobile_ai_erp/data/network/datasources/role/role_remote_datasource.dart';
import 'package:mobile_ai_erp/data/network/datasources/user/user_remote_datasource.dart';
import 'package:mobile_ai_erp/data/network/interceptors/error_interceptor.dart';
import 'package:mobile_ai_erp/data/network/interceptors/tenant_interceptor.dart';
import 'package:mobile_ai_erp/data/network/rest_client.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:event_bus/event_bus.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/storefront_api.dart';
import 'package:mobile_ai_erp/domain/repository/user/auth_repository.dart';

import '../../../di/service_locator.dart';

class NetworkModule {
  static const String erpDioClientName = 'erpDioClient';

  static Future<void> configureNetworkModuleInjection() async {
    // event bus:---------------------------------------------------------------
    getIt.registerSingleton<EventBus>(EventBus());

    // dio configs:---------------------------------------------------------------
    getIt.registerSingleton<DioConfigs>(
      const DioConfigs(
        baseUrl: Endpoints.erpBaseUrl,
        connectionTimeout: Endpoints.connectionTimeout,
        receiveTimeout: Endpoints.receiveTimeout,
      ),
    );

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
        saveAuthToken: (tokens) async {
          if (tokens.$1 != null && tokens.$2 != null) {
            await getIt<SharedPreferenceHelper>().saveAuthToken(accessToken: tokens.$1!, refreshToken: tokens.$2!);
          } else {
            await getIt<SharedPreferenceHelper>().removeTenantId();
            await getIt<SharedPreferenceHelper>().removeAuthToken();
          }
        },
        getNewTokens: () async {
          try {
            final SharedPreferenceHelper sharedPreferenceHelper = getIt<SharedPreferenceHelper>();
            final refreshToken = await sharedPreferenceHelper.refreshToken;
            if (refreshToken == null) {
              return (null, null);
            }
            final AuthRepository authRepository = getIt<AuthRepository>();
            final (newAccessToken, newRefreshToken) = await authRepository.refreshToken(refreshToken);
            return (newAccessToken, newRefreshToken ?? refreshToken);
          } catch (_) {
            return (null, null);
          }
        },
        tenantId: () async => await getIt<SharedPreferenceHelper>().tenantId,
        dioClient: DioClient(dioConfigs: getIt())
          ..addInterceptors([getIt<LoggingInterceptor>()]), // Separate Dio with same config
      ),
    );

    getIt.registerSingleton<TenantInterceptor>(
      TenantInterceptor(Endpoints.tenantId),
    );
    getIt.registerSingleton<TenantInterceptor>(
      TenantInterceptor(StorefrontEndpoints.tenantId),
      instanceName: 'storefront',
    );

    // rest client:-------------------------------------------------------------
    getIt.registerSingleton(RestClient());

    // dio (ERP backend - separate base URL + tenant header):-------------------
    final erpDioClient = DioClient(
      dioConfigs: getIt(),
    )..addInterceptors([
        getIt<TokenRefreshInterceptor>(),
        getIt<TenantHeaderInterceptor>(),
        getIt<AuthInterceptor>(),
        getIt<ErrorInterceptor>(),
        getIt<LoggingInterceptor>(),
      ]);
    getIt.registerSingleton<DioClient>(erpDioClient, instanceName: erpDioClientName);
    getIt.registerSingleton<DioClient>(erpDioClient);

    // storefront dio:---------------------------------------------------------------------
    getIt.registerSingleton<DioConfigs>(
      const DioConfigs(
        baseUrl: StorefrontEndpoints.baseUrl,
        connectionTimeout: StorefrontEndpoints.connectionTimeout,
        receiveTimeout: StorefrontEndpoints.receiveTimeout,
      ),
      instanceName: 'storefront',
    );
    getIt.registerSingleton<DioClient>(
      DioClient(dioConfigs: getIt<DioConfigs>(instanceName: 'storefront'))
        ..addInterceptors(
          [
            getIt<TenantInterceptor>(instanceName: 'storefront'),
            getIt<ErrorInterceptor>(),
            getIt<LoggingInterceptor>(),
          ],
        ),
      instanceName: 'storefront',
    );

    // api's:-------------------------------------------------------------------
    getIt.registerSingleton<WebBuilderApi>(
      WebBuilderApi(getIt<DioClient>(instanceName: erpDioClientName)),
    );
    getIt.registerSingleton(
      StorefrontApi(getIt<DioClient>(instanceName: 'storefront')),
    );
    getIt.registerSingleton(PostApi(getIt<DioClient>(), getIt<RestClient>()));

    // datasources:-----------------------------------------------------------
    getIt.registerSingleton<RoleRemoteDataSource>(
      RoleRemoteDataSourceImpl(dio: erpDioClient.dio),
    );
    getIt.registerSingleton<UserRemoteDataSource>(
      UserRemoteDataSourceImpl(erpDioClient.dio),
    );

    getIt.registerSingleton(SupplierApi(getIt<DioClient>(instanceName: erpDioClientName)));
    getIt.registerSingleton(OrderApi(getIt<DioClient>(instanceName: erpDioClientName)));
  }
}
