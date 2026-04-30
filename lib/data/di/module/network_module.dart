import 'package:mobile_ai_erp/core/data/network/dio/configs/dio_configs.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:mobile_ai_erp/data/network/apis/posts/post_api.dart';
import 'package:mobile_ai_erp/data/network/apis/web_builder/web_builder_api.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/data/network/datasources/role/role_remote_datasource.dart';
import 'package:mobile_ai_erp/data/network/datasources/user/user_remote_datasource.dart';
import 'package:mobile_ai_erp/data/network/interceptors/error_interceptor.dart';
import 'package:mobile_ai_erp/data/network/interceptors/tenant_interceptor.dart';
import 'package:mobile_ai_erp/data/network/rest_client.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:event_bus/event_bus.dart';

import '../../../di/service_locator.dart';

class NetworkModule {
  static const String erpDioClientName = 'erpDioClient';

  static Future<void> configureNetworkModuleInjection() async {
    // event bus:---------------------------------------------------------------
    getIt.registerSingleton<EventBus>(EventBus());

    // interceptors:------------------------------------------------------------
    getIt.registerSingleton<LoggingInterceptor>(LoggingInterceptor());
    getIt.registerSingleton<ErrorInterceptor>(ErrorInterceptor(getIt()));
    getIt.registerSingleton<AuthInterceptor>(
      AuthInterceptor(
        accessToken: () async => await getIt<SharedPreferenceHelper>().authToken,
      ),
    );

    getIt.registerSingleton<TenantInterceptor>(
      TenantInterceptor(Endpoints.tenantId),
    );

    // rest client:-------------------------------------------------------------
    getIt.registerSingleton(RestClient());

    // dio (legacy posts API):--------------------------------------------------
    getIt.registerSingleton<DioConfigs>(
      const DioConfigs(
        baseUrl: Endpoints.baseUrl,
        connectionTimeout: Endpoints.connectionTimeout,
        receiveTimeout: Endpoints.receiveTimeout,
      ),
    );
    getIt.registerSingleton<DioClient>(
      DioClient(dioConfigs: getIt())
        ..addInterceptors(
          [
            getIt<AuthInterceptor>(),
            getIt<TenantInterceptor>(),
            getIt<ErrorInterceptor>(),
            getIt<LoggingInterceptor>(),
          ],
        ),
    );

    // api's:-------------------------------------------------------------------
    getIt.registerSingleton(PostApi(getIt<DioClient>(), getIt<RestClient>()));

    // datasources:-----------------------------------------------------------
    getIt.registerSingleton<RoleRemoteDataSource>(
      RoleRemoteDataSourceImpl(dio: getIt<DioClient>().dio),
    );
    getIt.registerSingleton<UserRemoteDataSource>(
      UserRemoteDataSourceImpl(getIt<DioClient>().dio),
    );
    // dio (ERP backend - separate base URL + tenant header):-------------------
    final erpDioClient = DioClient(
      dioConfigs: const DioConfigs(
        baseUrl: Endpoints.erpBaseUrl,
        connectionTimeout: Endpoints.connectionTimeout,
        receiveTimeout: Endpoints.receiveTimeout,
      ),
    )..addInterceptors([
        getIt<AuthInterceptor>(),
        getIt<TenantInterceptor>(),
        getIt<ErrorInterceptor>(),
        getIt<LoggingInterceptor>(),
      ]);
    getIt.registerSingleton<DioClient>(erpDioClient, instanceName: erpDioClientName);

    // api's:-------------------------------------------------------------------
    getIt.registerSingleton<WebBuilderApi>(
      WebBuilderApi(getIt<DioClient>(instanceName: erpDioClientName)),
    );
  }
}
