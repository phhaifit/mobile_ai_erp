import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/data/local/datasources/checkout/checkout_datasource.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/customer_api.dart';
import 'package:mobile_ai_erp/data/network/apis/customer/customer_segment_api.dart';
import 'package:mobile_ai_erp/data/local/datasources/order_tracking/order_tracking_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/post/post_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/post_purchase/post_purchase_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/user/user_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/storefront_address/address_api_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/storefront_order/order_api_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/storefront_customer/customer_api_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/loyalty_ledgers/loyalty_ledger_api_datasource.dart';
import 'package:mobile_ai_erp/data/network/apis/posts/post_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront_customer/customer_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront_address/address_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront_order/order_api.dart';
import 'package:mobile_ai_erp/data/network/apis/loyalty_ledgers/loyalty_ledger_api.dart';
import 'package:mobile_ai_erp/data/repository/customer/customer_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/storefront_account/customer_repository_impl.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';
import 'package:mobile_ai_erp/data/network/apis/product/product_api.dart';
import 'package:mobile_ai_erp/data/network/datasources/user/user_remote_datasource.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/datasources/role/role_remote_datasource.dart';
import 'package:mobile_ai_erp/data/network/apis/orders/order_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/brand_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/brand_image_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/category_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/tag_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/attribute_set_api.dart';
import 'package:mobile_ai_erp/data/network/apis/product_metadata/metadata_api_client.dart';
import 'package:mobile_ai_erp/data/network/apis/posts/post_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront_products_api.dart';
import 'package:mobile_ai_erp/data/network/apis/suppliers/supplier_api.dart';
import 'package:mobile_ai_erp/data/network/apis/web_builder/web_builder_api.dart';
import 'package:mobile_ai_erp/data/repository/checkout/checkout_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/customer/customer_repository_impl.dart';
import 'package:mobile_ai_erp/data/network/apis/dashboard/dashboard_api.dart';
import 'package:mobile_ai_erp/data/repository/dashboard/live_dashboard_repository.dart';
import 'package:mobile_ai_erp/data/repository/fulfillment/fulfillment_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/inventory_audit_outbound/mock_inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/data/repository/order_tracking/order_tracking_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/post/post_repository_impl.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_all_users_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_user_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/create_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/update_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/delete_user_usecase.dart';
import 'package:mobile_ai_erp/data/repository/post_purchase/post_purchase_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/setting/setting_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/stock_operations/stock_operations_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/storefront/storefront_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/supplier/supplier_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/user/role_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/user/user_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/web_builder/cms_page_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/web_builder/store_settings_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/web_builder/web_theme_repository_impl.dart';
import 'package:mobile_ai_erp/domain/repository/checkout/checkout_repository.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/repository/account/order_repository.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';
import 'package:mobile_ai_erp/domain/repository/dashboard/dashboard_repository.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/domain/repository/order_tracking/order_tracking_repository.dart';
import 'package:mobile_ai_erp/domain/repository/post/post_repository.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/domain/repository/setting/setting_repository.dart';
import 'package:mobile_ai_erp/domain/repository/stock_operations/stock_operations_repository.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/domain/repository/storefront_account/customer_repository.dart';
import 'package:mobile_ai_erp/domain/repository/storefront_account/address_repository.dart';
import 'package:mobile_ai_erp/domain/repository/storefront_account/order_repository.dart';
import 'package:mobile_ai_erp/domain/repository/storefront_account/loyalty_ledger_repository.dart';
import 'package:mobile_ai_erp/domain/repository/supplier/supplier_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/data/repository/storefront_account/address_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/storefront_account/order_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/storefront_account/loyalty_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/user/auth_repository_impl.dart';
import 'package:mobile_ai_erp/domain/repository/user/auth_repository.dart';
import 'package:mobile_ai_erp/data/local/datasources/account/address_mock_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/account/order_mock_datasource.dart';
import 'package:mobile_ai_erp/domain/repository/account/payment_repository.dart';
import 'package:mobile_ai_erp/data/repository/account/order_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/account/payment_repository_impl.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/addresses_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/checkout_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/storefront_orders_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/storefront_payments_api.dart';
import 'package:mobile_ai_erp/data/network/apis/coupon/coupon_api.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/store_settings_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/web_theme_repository.dart';

import 'package:mobile_ai_erp/data/repository/product/product_management_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/product/product_detail_repository_impl.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_management_repository.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_detail_repository.dart';
import 'package:mobile_ai_erp/data/local/datasources/product/mock_product_datasource.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/storefront_api.dart';

import '../../../di/service_locator.dart';

class RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    getIt.registerSingleton<CustomerRepository>(
      CustomerRepositoryImpl(getIt<CustomerApi>(), getIt<CustomerSegmentApi>()),
    );

        getIt.registerSingleton<DashboardRepository>(
      LiveDashboardRepository(getIt<DashboardApi>()),
    );

    getIt.registerSingleton<SettingRepository>(
      SettingRepositoryImpl(getIt<SharedPreferenceHelper>()),
    );

    getIt.registerSingleton<PostRepository>(
      PostRepositoryImpl(getIt<PostApi>(), getIt<PostDataSource>()),
    );

    getIt.registerSingleton<StockOperationsRepository>(
      StockOperationsRepositoryImpl(
        getIt<DioClient>(),
        getIt<SharedPreferenceHelper>(),
      ),
    );

    getIt.registerSingleton<StorefrontRepository>(
      StorefrontRepositoryImpl(getIt<StorefrontApi>()),
    );

    getIt.registerSingleton<InventoryAuditOutboundRepository>(
      MockInventoryAuditOutboundRepository(),
    );

    getIt.registerSingleton<OrderTrackingDataSource>(OrderTrackingDataSource());
    getIt.registerSingleton<OrderTrackingRepository>(
      OrderTrackingRepositoryImpl(getIt<OrderTrackingDataSource>()),
    );

    getIt.registerSingleton<MetadataApiClient>(
      MetadataApiClient(
        brands: getIt<BrandApi>(),
        brandImages: getIt<BrandImageApi>(),
        categories: getIt<CategoryApi>(),
        tags: getIt<TagApi>(),
        attributeSets: getIt<AttributeSetApi>(),
      ),
    );

    getIt.registerSingleton<ProductMetadataRepository>(
      ProductMetadataRepositoryImpl(getIt<MetadataApiClient>()),
    );
    
    getIt.registerLazySingleton<AccountCustomerApiDataSource>(
        () => AccountCustomerApiDataSource(getIt<StorefrontCustomerApi>(), getIt<SharedPreferenceHelper>()));

    getIt.registerLazySingleton<AccountCustomerRepository>(
        () => AccountCustomerRepositoryImpl(getIt<AccountCustomerApiDataSource>()));

    getIt.registerLazySingleton<AddressApiDataSource>(
        () => AddressApiDataSource(getIt<StorefrontAddressApi>(), getIt<SharedPreferenceHelper>()));
    getIt.registerLazySingleton<OrderApiDataSource>(
        () => OrderApiDataSource(getIt<StorefrontOrderApi>(), getIt<SharedPreferenceHelper>()));
    getIt.registerLazySingleton<LoyaltyLedgerApiDataSource>(
        () => LoyaltyLedgerApiDataSource(getIt<LoyaltyLedgerApi>()));

    getIt.registerLazySingleton<StorefrontAddressRepository>(
        () => AddressRepositoryImpl(getIt<AddressApiDataSource>()));
        
    getIt.registerLazySingleton<StorefrontOrderRepository>(
        () => StorefrontOrderRepositoryImpl(getIt<OrderApiDataSource>()));
        
    getIt.registerLazySingleton<LoyaltyLedgerRepository>(
        () => LoyaltyRepositoryImpl(getIt<LoyaltyLedgerApiDataSource>()));

    getIt.registerLazySingleton<PaymentRepository>(
        () => PaymentRepositoryImpl(getIt<StorefrontPaymentsApi>()));

    // post_purchase:----------------------------------------------------------
    getIt.registerSingleton<PostPurchaseDataSource>(PostPurchaseDataSource());
    getIt.registerSingleton<PostPurchaseRepository>(
      PostPurchaseRepositoryImpl(getIt<PostPurchaseDataSource>()),
    );

    // user:---------------------------------------------------------------------
    getIt.registerSingleton<UserDataSource>(UserDataSource());
    getIt.registerSingleton<UserRepository>(
      UserRepositoryImpl(getIt<UserRemoteDataSource>()),
    );
    getIt.registerSingleton<RoleRepository>(
      RoleRepositoryImpl(getIt<RoleRemoteDataSource>()),
    );
    getIt.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(getIt(), getIt<Dio>(instanceName: 'refreshDio')),
    );

    // web_builder:--------------------------------------------------------------
    getIt.registerLazySingleton<CmsPageRepository>(
      () => CmsPageRepositoryImpl(getIt<WebBuilderApi>()),
    );
    getIt.registerLazySingleton<WebThemeRepository>(
      () => WebThemeRepositoryImpl(getIt<WebBuilderApi>()),
    );
    getIt.registerLazySingleton<StoreSettingsRepository>(
      () => StoreSettingsRepositoryImpl(getIt<WebBuilderApi>()),
    );

    getIt.registerLazySingleton<SupplierRepository>(
      () => SupplierRepositoryImpl(getIt<SupplierApi>()),
    );
    getIt.registerSingleton<FulfillmentRepository>(
      FulfillmentRepositoryImpl(getIt<OrderApi>()),
    );

    // user use cases:---------------------------------------------------------
    getIt.registerSingleton<GetAllUsersUseCase>(GetAllUsersUseCase(getIt()));
    getIt.registerSingleton<GetUserByIdUseCase>(GetUserByIdUseCase(getIt()));
    getIt.registerSingleton<CreateUserUseCase>(CreateUserUseCase(getIt()));
    getIt.registerSingleton<UpdateUserUseCase>(UpdateUserUseCase(getIt()));
    getIt.registerSingleton<DeleteUserUseCase>(DeleteUserUseCase(getIt()));

    // checkout:--------------------------------------------------------------
    getIt.registerSingleton<CheckoutDataSource>(CheckoutLocalDataSourceImpl());
    getIt.registerSingleton<CheckoutRepository>(
      CheckoutRepositoryImpl(
        getIt<CheckoutDataSource>(),
        getIt<CheckoutApi>(),
        getIt<AddressesApi>(),
        getIt<CouponApi>(),
      ),
    );

    getIt.registerSingleton<ProductManagementRepository>(
      ProductManagementRepositoryImpl(getIt<MockProductDataSource>(), getIt<ProductApi>()),
    );

    getIt.registerLazySingleton<ProductDetailRepository>(
      () => ProductDetailRepositoryImpl(getIt<StorefrontProductsApi>()),
    );
  }
}
