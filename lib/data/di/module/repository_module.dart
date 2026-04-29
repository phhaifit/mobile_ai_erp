import 'dart:async';

import 'package:mobile_ai_erp/data/local/datasources/checkout/checkout_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/customer/customer_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/order_tracking/order_tracking_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/post/post_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/post_purchase/post_purchase_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/product_metadata/product_metadata_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/user/role_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/user/user_datasource.dart';
import 'package:mobile_ai_erp/core/data/network/dio/dio_client.dart';
import 'package:mobile_ai_erp/data/network/apis/posts/post_api.dart';
import 'package:mobile_ai_erp/data/repository/checkout/checkout_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/customer/customer_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/dashboard/mock_dashboard_repository.dart';
import 'package:mobile_ai_erp/data/repository/fulfillment/fulfillment_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/inventory_audit_outbound/mock_inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/data/repository/order_tracking/order_tracking_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/post/post_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/post_purchase/post_purchase_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/product_metadata/product_metadata_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/setting/setting_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/stock_operations/stock_operations_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/supplier/supplier_mock_repository.dart';
import 'package:mobile_ai_erp/data/repository/user/role_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/user/user_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/web_builder/cms_page_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/web_builder/store_settings_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/web_builder/web_theme_repository_impl.dart';
import 'package:mobile_ai_erp/domain/repository/checkout/checkout_repository.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
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
import 'package:mobile_ai_erp/domain/repository/supplier/supplier_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/domain/repository/account/address_repository.dart';
import 'package:mobile_ai_erp/domain/repository/account/order_repository.dart';
import 'package:mobile_ai_erp/data/repository/account/address_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/account/order_repository_impl.dart';
import 'package:mobile_ai_erp/data/local/datasources/account/address_mock_datasource.dart';
import 'package:mobile_ai_erp/data/local/datasources/account/order_mock_datasource.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/store_settings_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/web_theme_repository.dart';

import 'package:mobile_ai_erp/data/repository/product/product_management_repository_impl.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_management_repository.dart';
import 'package:mobile_ai_erp/data/local/datasources/product/mock_product_datasource.dart';

import '../../../di/service_locator.dart';

class RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    getIt.registerSingleton<CustomerDataSource>(CustomerDataSource());
    getIt.registerSingleton<CustomerRepository>(
      CustomerRepositoryImpl(getIt<CustomerDataSource>()),
    );

    getIt.registerSingleton<DashboardRepository>(MockDashboardRepository());

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

    getIt.registerSingleton<InventoryAuditOutboundRepository>(
      MockInventoryAuditOutboundRepository(),
    );

    getIt.registerSingleton<OrderTrackingDataSource>(OrderTrackingDataSource());
    getIt.registerSingleton<OrderTrackingRepository>(
      OrderTrackingRepositoryImpl(getIt<OrderTrackingDataSource>()),
    );

    getIt.registerSingleton<ProductMetadataDataSource>(
      ProductMetadataDataSource(),
    );
    getIt.registerSingleton<ProductMetadataRepository>(
      ProductMetadataRepositoryImpl(getIt<ProductMetadataDataSource>()),
    );

    getIt.registerLazySingleton<AddressRepository>(
      () => AddressRepositoryImpl(getIt<AddressMockDataSource>()),
    );

    getIt.registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(getIt<OrderMockDataSource>()),
    );

    // post_purchase:----------------------------------------------------------
    getIt.registerSingleton<PostPurchaseDataSource>(PostPurchaseDataSource());
    getIt.registerSingleton<PostPurchaseRepository>(
      PostPurchaseRepositoryImpl(getIt<PostPurchaseDataSource>()),
    );

    // user:---------------------------------------------------------------------
    getIt.registerSingleton<UserDataSource>(UserDataSource());
    getIt.registerSingleton<RoleDataSource>(RoleDataSource());
    getIt.registerSingleton<UserRepository>(
      UserRepositoryImpl(getIt<UserDataSource>()),
    );
    getIt.registerSingleton<RoleRepository>(
      RoleRepositoryImpl(getIt<RoleDataSource>()),
    );

    // web_builder:--------------------------------------------------------------
    getIt.registerLazySingleton<CmsPageRepository>(
      () => CmsPageRepositoryImpl(),
    );
    getIt.registerLazySingleton<WebThemeRepository>(
      () => WebThemeRepositoryImpl(),
    );
    getIt.registerLazySingleton<StoreSettingsRepository>(
      () => StoreSettingsRepositoryImpl(),
    );

    getIt.registerLazySingleton<SupplierRepository>(
      () => SupplierMockRepository(),
    );
    getIt.registerSingleton<FulfillmentRepository>(FulfillmentRepositoryImpl());

    // checkout:--------------------------------------------------------------
    getIt.registerSingleton<CheckoutDataSource>(CheckoutLocalDataSourceImpl());
    getIt.registerSingleton<CheckoutRepository>(
      CheckoutRepositoryImpl(getIt<CheckoutDataSource>()),
    );

    getIt.registerSingleton<ProductManagementRepository>(
      ProductManagementRepositoryImpl(getIt<MockProductDataSource>()),
    );
  }
}
