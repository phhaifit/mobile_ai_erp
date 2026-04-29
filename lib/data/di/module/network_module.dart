import 'package:mobile_ai_erp/core/data/network/dio/configs/dio_configs.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:mobile_ai_erp/data/network/apis/posts/post_api.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/customer_api.dart';
import 'package:mobile_ai_erp/data/network/apis/address/address_api.dart';
import 'package:mobile_ai_erp/data/network/apis/order/order_api.dart';
import 'package:mobile_ai_erp/data/network/apis/loyalty_ledgers/loyalty_ledger_api.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/data/network/interceptors/error_interceptor.dart';
import 'package:mobile_ai_erp/data/network/interceptors/tenant_interceptor.dart';
import 'package:mobile_ai_erp/data/network/rest_client.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    getIt.registerSingleton<TenantInterceptor>(
      TenantInterceptor(dotenv.env['TENANT_ID'] ?? 'default-tenant-id'),
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
            getIt<ErrorInterceptor>(),
            getIt<LoggingInterceptor>(),
          ],
        ),
    );

    // customer dio:-----------------------------------------------------------
    getIt.registerSingleton<DioConfigs>(
      const DioConfigs(
        baseUrl: Endpoints.storefrontAccountUrl,
        connectionTimeout: Endpoints.connectionTimeout,
        receiveTimeout: Endpoints.receiveTimeout,
      ),
      instanceName: 'customer',
    );
    getIt.registerSingleton<DioClient>(
      DioClient(dioConfigs: getIt(instanceName: 'customer'))
        ..addInterceptors(
          [
            getIt<AuthInterceptor>(),
            getIt<TenantInterceptor>(),
            getIt<ErrorInterceptor>(),
            getIt<LoggingInterceptor>(),
          ],
        ),
      instanceName: 'customer',
    );

    // api's:-------------------------------------------------------------------
    getIt.registerSingleton(PostApi(getIt<DioClient>(), getIt<RestClient>()));
    getIt.registerSingleton<CustomerApi>(CustomerApi(getIt<DioClient>(instanceName: 'customer')));
    getIt.registerSingleton<AddressApi>(AddressApi(getIt<DioClient>(instanceName: 'customer')));
    getIt.registerSingleton<OrderApi>(OrderApi(getIt<DioClient>(instanceName: 'customer')));
    getIt.registerSingleton<LoyaltyLedgerApi>(LoyaltyLedgerApi(getIt<DioClient>(instanceName: 'customer')));
  }
}
