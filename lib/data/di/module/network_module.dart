import 'package:mobile_ai_erp/core/data/network/dio/configs/dio_configs.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/tenant_interceptor_userrole_management.dart';
import 'package:mobile_ai_erp/core/services/tenant_service.dart';
import 'package:mobile_ai_erp/data/network/apis/posts/post_api.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/data/network/datasources/role/role_remote_datasource.dart';
import 'package:mobile_ai_erp/data/network/datasources/user/user_remote_datasource.dart';
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
        accessToken: () async => await getIt<SharedPreferenceHelper>().authToken,
      ),
    );
    getIt.registerSingleton<TenantInterceptorUserRoleMananagement>(
      TenantInterceptorUserRoleMananagement(
        tenantId: () async => await getIt<TenantService>().getCurrentTenantId(),
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
            getIt<AuthInterceptor>(),
            getIt<TenantInterceptorUserRoleMananagement>(),
            getIt<ErrorInterceptor>(),
            getIt<LoggingInterceptor>(),
          ],
        ),
    );

    // services:----------------------------------------------------------------
    getIt.registerSingleton<TenantService>(TenantService());

    // api's:-------------------------------------------------------------------
    getIt.registerSingleton(PostApi(getIt<DioClient>(), getIt<RestClient>()));

    // datasources:-----------------------------------------------------------
    getIt.registerSingleton<RoleRemoteDataSource>(
      RoleRemoteDataSourceImpl(dio: getIt<DioClient>().dio),
    );
    getIt.registerSingleton<UserRemoteDataSource>(
      UserRemoteDataSourceImpl(getIt<DioClient>().dio),
    );
  }
}
