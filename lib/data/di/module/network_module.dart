import 'package:mobile_ai_erp/constants/env.dart';
import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/core/data/network/dio/configs/dio_configs.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/tenant_header_interceptor.dart';
import 'package:mobile_ai_erp/core/data/network/dio/interceptors/token_refresh_interceptor.dart';
import 'package:mobile_ai_erp/data/network/apis/dashboard/dashboard_api.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/customer_api.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/customer_segment_api.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/order_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/brand_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/brand_image_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/category_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/tag_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/attribute_set_api.dart';
import 'package:mobile_ai_erp/data/network/apis/posts/post_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront_products_api.dart';
import 'package:mobile_ai_erp/data/network/apis/web_builder/web_builder_api.dart';
import 'package:mobile_ai_erp/data/network/apis/cart/cart_api.dart';
import 'package:mobile_ai_erp/data/network/apis/wishlist/wishlist_api.dart';
import 'package:mobile_ai_erp/data/network/apis/coupon/coupon_api.dart';
import 'package:mobile_ai_erp/data/network/apis/suppliers/supplier_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/addresses_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/checkout_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/storefront_orders_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/storefront_payments_api.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/data/network/constants/storefront_endpoints.dart';
import 'package:mobile_ai_erp/data/network/datasources/role/role_remote_datasource.dart';
import 'package:mobile_ai_erp/data/network/datasources/user/user_remote_datasource.dart';
import 'package:mobile_ai_erp/data/network/interceptors/error_interceptor.dart';
import 'package:mobile_ai_erp/data/network/interceptors/tenant_interceptor.dart';
import 'package:mobile_ai_erp/data/network/rest_client.dart';
import 'package:mobile_ai_erp/data/sharedpref/customer_shared_preference_helper.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:event_bus/event_bus.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/storefront_api.dart';
import 'package:mobile_ai_erp/domain/repository/customer_auth_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/auth_repository.dart';
import 'package:mobile_ai_erp/presentation/customer/store/auth_store.dart';
import 'package:mobile_ai_erp/presentation/login/store/login_store.dart';

import '../../../di/service_locator.dart';

bool defaultValidateStatusIgnoreRedirect(int? status) {
  return (status != null && status >= 200 && status < 300) || status == 302;
}

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
        validateStatus: defaultValidateStatusIgnoreRedirect,
      ),
    );

    // interceptors:------------------------------------------------------------
    getIt.registerSingleton<LoggingInterceptor>(LoggingInterceptor());
    getIt.registerSingleton<ErrorInterceptor>(ErrorInterceptor(getIt()));
    getIt.registerSingleton<AuthInterceptor>(
      AuthInterceptor(
        accessToken: () async {
          const envToken = String.fromEnvironment('ACCESS_TOKEN');

          if (envToken.isNotEmpty) {
            return envToken;
          }

          return await getIt<SharedPreferenceHelper>().accessToken;
        },
      ),
    );
    getIt.registerSingleton<TenantHeaderInterceptor>(
      TenantHeaderInterceptor(
        subdomain: () async => getIt<SharedPreferenceHelper>().subdomain,
        tenantId: () async {
          final storedTenantId = await getIt<SharedPreferenceHelper>().tenantId;

          if (storedTenantId != null && storedTenantId.isNotEmpty) {
            return storedTenantId;
          }

          return Endpoints.tenantId;
        },
      ),
    );
    getIt.registerSingleton<TokenRefreshInterceptor>(
      TokenRefreshInterceptor(
        accessToken: () async =>
            await getIt<SharedPreferenceHelper>().accessToken,
        getRefreshToken: () async =>
            await getIt<SharedPreferenceHelper>().refreshToken,
        saveAuthToken: (tokens) async {
          if (tokens.$1 != null && tokens.$2 != null) {
            await getIt<SharedPreferenceHelper>().saveAuthToken(accessToken: tokens.$1!, refreshToken: tokens.$2!);
          } else if (!Env.isCustomerApp) {
            await getIt<LoginStore>().logout();
            await getIt<SharedPreferenceHelper>().removeSessionId();
          } else {
            await getIt<CustomerAuthStore>().logout();
          }
        },
        getNewTokens: () async {
          try {
            final SharedPreferenceHelper sharedPreferenceHelper =
                getIt<SharedPreferenceHelper>();
            final refreshToken = await sharedPreferenceHelper.refreshToken;
            if (refreshToken == null) {
              return (null, null);
            }
            if (Env.isCustomerApp) {
              final sessionId = getIt<CustomerSharedPreferenceHelper>().customerSessionId;
              if (sessionId == null) {
                return (null, null);
              }
              return await getIt<CustomerAuthRepository>().refreshToken(refreshToken: refreshToken, sessionId: sessionId);
            } else {
              final sessionId = await sharedPreferenceHelper.sessionId;
              final AuthRepository authRepository = getIt<AuthRepository>();
              final (newAccessToken, newRefreshToken, newSessionId) = await authRepository.refreshToken(
                refreshToken,
                sessionId: sessionId,
              );
              // Save new sessionId if returned
              if (newSessionId != null && newSessionId.isNotEmpty) {
                await sharedPreferenceHelper.saveSessionId(newSessionId);
              }
              return (newAccessToken, newRefreshToken ?? refreshToken);
            }
          } catch (_) {
            return (null, null);
          }
        },
        tenantId: () async => await getIt<SharedPreferenceHelper>().tenantId,
        dioClient: DioClient(dioConfigs: getIt())
          ..addInterceptors([
            getIt<LoggingInterceptor>(),
          ]), // Separate Dio with same config
      ),
    );

    getIt.registerSingleton<TenantInterceptor>(
      TenantInterceptor(StorefrontEndpoints.tenantId),
      instanceName: 'storefront',
    );

    // rest client:-------------------------------------------------------------
    getIt.registerSingleton(RestClient());

    // Clean Dio for token refresh (no auth interceptors to avoid infinite loop)
    getIt.registerSingleton<Dio>(
      Dio(BaseOptions(
        baseUrl: Endpoints.erpBaseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 15000),
      )),
      instanceName: 'refreshDio',
    );

    // dio (ERP backend - separate base URL + tenant header):-------------------
    final erpDioClient = DioClient(dioConfigs: getIt())
      ..addInterceptors([
        getIt<TokenRefreshInterceptor>(),
        getIt<TenantHeaderInterceptor>(),
        getIt<AuthInterceptor>(),
        getIt<ErrorInterceptor>(),
        getIt<LoggingInterceptor>(),
      ]);
    getIt.registerSingleton<DioClient>(
      erpDioClient,
      instanceName: erpDioClientName,
    );
    getIt.registerSingleton<DioClient>(erpDioClient);

    // dio (storefront backend - separate base URL + storefront tenant):--------
    final storefrontDioClient =
        DioClient(
          dioConfigs: const DioConfigs(
            baseUrl: StorefrontEndpoints.baseUrl,
            connectionTimeout: StorefrontEndpoints.connectionTimeout,
            receiveTimeout: StorefrontEndpoints.receiveTimeout,
          ),
        )..addInterceptors([
          getIt<TenantInterceptor>(instanceName: 'storefront'),
          getIt<ErrorInterceptor>(),
          getIt<LoggingInterceptor>(),
        ]);
    getIt.registerSingleton<DioClient>(
      storefrontDioClient,
      instanceName: 'storefront',
    );

    // api's:-------------------------------------------------------------------
    getIt.registerSingleton<WebBuilderApi>(
      WebBuilderApi(getIt<DioClient>(instanceName: erpDioClientName)),
    );
    getIt.registerSingleton<CartApi>(
      CartApi(getIt<DioClient>(instanceName: erpDioClientName)),
    );

    getIt.registerSingleton<WishlistApi>(
      WishlistApi(getIt<DioClient>(instanceName: erpDioClientName)),
    );

    getIt.registerSingleton<CouponApi>(
      CouponApi(getIt<DioClient>(instanceName: erpDioClientName)),
    );
    getIt.registerSingleton(
      StorefrontApi(getIt<DioClient>(instanceName: 'storefront')),
    );
    getIt.registerSingleton(BrandApi(getIt<DioClient>(instanceName: erpDioClientName)));
    getIt.registerSingleton(BrandImageApi(getIt<DioClient>(instanceName: erpDioClientName)));
    getIt.registerSingleton(CategoryApi(getIt<DioClient>(instanceName: erpDioClientName)));
    getIt.registerSingleton(TagApi(getIt<DioClient>(instanceName: erpDioClientName)));
    getIt.registerSingleton(AttributeSetApi(getIt<DioClient>(instanceName: erpDioClientName)));
    getIt.registerSingleton(PostApi(getIt<DioClient>(), getIt<RestClient>()));

    // customer apis:----------------------------------------------------------
    getIt.registerSingleton<CustomerSegmentApi>(
      CustomerSegmentApi(getIt<DioClient>(instanceName: erpDioClientName)),
    );
    getIt.registerSingleton<CustomerApi>(
      CustomerApi(getIt<DioClient>(instanceName: erpDioClientName)),
    );

    // datasources:-----------------------------------------------------------
    getIt.registerSingleton<RoleRemoteDataSource>(
      RoleRemoteDataSourceImpl(dio: erpDioClient.dio),
    );
    getIt.registerSingleton<UserRemoteDataSource>(
      UserRemoteDataSourceImpl(erpDioClient.dio),
    );

        getIt.registerSingleton(
      SupplierApi(getIt<DioClient>(instanceName: erpDioClientName)),
    );
    getIt.registerSingleton(
      OrderApi(getIt<DioClient>(instanceName: erpDioClientName)),
    );

    // dashboard:---------------------------------------------------------------
    getIt.registerSingleton<DashboardApi>(
      DashboardApi(getIt<DioClient>(instanceName: erpDioClientName)),
    );
    getIt.registerSingleton<StorefrontProductsApi>(
      StorefrontProductsApi(getIt<DioClient>(instanceName: erpDioClientName).dio),
    );

    // storefront: addresses, checkout, orders, payments
    getIt.registerSingleton<AddressesApi>(
      AddressesApi(getIt<DioClient>(instanceName: erpDioClientName).dio),
    );
    getIt.registerSingleton<CheckoutApi>(
      CheckoutApi(getIt<DioClient>(instanceName: erpDioClientName).dio),
    );
    getIt.registerSingleton<StorefrontOrdersApi>(
      StorefrontOrdersApi(getIt<DioClient>(instanceName: erpDioClientName).dio),
    );
    getIt.registerSingleton<StorefrontPaymentsApi>(
      StorefrontPaymentsApi(getIt<DioClient>(instanceName: erpDioClientName).dio),
    );
  }
}
