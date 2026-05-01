import 'dart:async';

import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/core/stores/form/form_store.dart';
import 'package:mobile_ai_erp/presentation/supplier/store/supplier_store.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/presentation/supplier/store/supplier_products_store.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';
import 'package:mobile_ai_erp/domain/repository/dashboard/dashboard_repository.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/domain/repository/setting/setting_repository.dart';
import 'package:mobile_ai_erp/domain/repository/stock_operations/stock_operations_repository.dart';
import 'package:mobile_ai_erp/domain/repository/storefront/storefront_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/supplier/supplier_usecases.dart';
import 'package:mobile_ai_erp/domain/repository/user/auth_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/checkout_usecases.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/get_payment_methods_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/get_shipping_methods_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/validate_coupon_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/create_or_link_shipment_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/apply_order_routing_recommendation_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/create_shipment_print_attempt_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/create_shipment_print_job_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_order_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_orders_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_order_routing_recommendation_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_order_shipments_tracking_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_shipment_label_artifacts_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_shipment_print_jobs_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_shipment_tracking_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/update_fulfillment_status_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_issue_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_issue_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_order_pool_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/create_issue_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/execute_issue_action_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_issue_notes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_exchange_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_exchange_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/create_exchange_from_issue_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/execute_exchange_action_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_exchange_notes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_refund_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_refund_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/create_refund_from_issue_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/execute_refund_action_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_refund_notes_usecase.dart';
import 'package:mobile_ai_erp/presentation/checkout/store/checkout_store.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_audit_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_by_warehouse_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_outbound_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_warehouses_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/save_inventory_audit_session_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/submit_inventory_outbound_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/order_tracking/find_order_tracking_scenario_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/order_tracking/get_order_tracking_scenarios_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/get_post_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/assign_role_to_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/create_role_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/delete_role_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_all_roles_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_role_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/update_role_usercase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_all_users_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_user_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/create_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/update_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/delete_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/auth/create_tenant_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/apply_web_theme_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/delete_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_cms_page_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_cms_pages_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_store_settings_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_web_theme_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_web_themes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/publish_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/save_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/save_store_settings_usecase.dart';
import 'package:mobile_ai_erp/presentation/customer_management/store/customer_store.dart';
import 'package:mobile_ai_erp/presentation/dashboard/store/dashboard_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/language/language_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/theme/theme_store.dart';
import 'package:mobile_ai_erp/presentation/inventory_audit_outbound/store/inventory_audit_outbound_store.dart';
import 'package:mobile_ai_erp/presentation/login/store/login_store.dart'
    as auth;
import 'package:mobile_ai_erp/presentation/order_fulfillment/store/fulfillment_store.dart';
import 'package:mobile_ai_erp/presentation/order_tracking/store/order_tracking_store.dart';
import 'package:mobile_ai_erp/presentation/post/store/post_store.dart';
import 'package:mobile_ai_erp/presentation/product_detail/store/product_detail_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/store/product_metadata_store.dart';
import 'package:mobile_ai_erp/presentation/reports/data/reports_mock_repository.dart';
import 'package:mobile_ai_erp/presentation/reports/store/reports_store.dart';
import 'package:mobile_ai_erp/presentation/account/store/profile_store.dart';
import 'package:mobile_ai_erp/presentation/account/store/address_store.dart';
import 'package:mobile_ai_erp/presentation/account/store/order_store.dart';
import 'package:mobile_ai_erp/domain/repository/account/address_repository.dart';
import 'package:mobile_ai_erp/domain/repository/account/order_repository.dart';
import 'package:mobile_ai_erp/presentation/stock_operations/store/stock_operations_store.dart';
import 'package:mobile_ai_erp/presentation/user/store/role_store.dart';
import 'package:mobile_ai_erp/presentation/user/store/user_store.dart'
    as user_mgmt;
import 'package:mobile_ai_erp/presentation/web_builder/store/cms_page_store.dart';
import 'package:mobile_ai_erp/presentation/web_builder/store/store_settings_store.dart';
import 'package:mobile_ai_erp/presentation/web_builder/store/web_theme_store.dart';
import 'package:mobile_ai_erp/presentation/post_purchase/store/post_purchase_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/store/product_listing_store.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/cart/store/wishlist_store.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:mobile_ai_erp/data/repository/wishlist/wishlist_repository.dart';
import 'package:mobile_ai_erp/data/repository/coupon/coupon_repository.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_form_store.dart';
import 'package:mobile_ai_erp/presentation/product/store/product_store.dart';
import 'package:mobile_ai_erp/domain/repository/product/product_management_repository.dart';

import '../../../di/service_locator.dart';

class StoreModule {
  static Future<void> configureStoreModuleInjection() async {
    getIt.registerFactory(() => ErrorStore());
    getIt.registerFactory(() => FormErrorStore());
    getIt.registerFactory(
      () => FormStore(getIt<FormErrorStore>(), getIt<ErrorStore>()),
    );

    getIt.registerLazySingleton<ProfileStore>(() => ProfileStore());
    getIt.registerLazySingleton<AddressStore>(
      () => AddressStore(getIt<AddressRepository>()),
    );
    getIt.registerLazySingleton<OrderStore>(
      () => OrderStore(getIt<OrderRepository>()),
    );
    getIt.registerLazySingleton(() => ReportsMockRepository());

    getIt.registerSingleton<auth.LoginStore>(
      auth.LoginStore(
        getIt<CreateTenantUseCase>(),
        getIt<AuthRepository>(),
        getIt<SharedPreferenceHelper>(),
        getIt<FormErrorStore>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<PostStore>(
      PostStore(getIt<GetPostUseCase>(), getIt<ErrorStore>()),
    );

    getIt.registerSingleton<ReportsStore>(
      ReportsStore(getIt<ReportsMockRepository>(), getIt<ErrorStore>()),
    );

    getIt.registerSingleton<DashboardStore>(
      DashboardStore(getIt<DashboardRepository>(), getIt<ErrorStore>()),
    );

    getIt.registerSingleton<ProductMetadataStore>(
      ProductMetadataStore(
        getIt<ProductMetadataRepository>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<CustomerStore>(
      CustomerStore(getIt<CustomerRepository>(), getIt<ErrorStore>()),
    );

    getIt.registerSingleton<OrderTrackingStore>(
      OrderTrackingStore(
        getIt<GetOrderTrackingScenariosUseCase>(),
        getIt<FindOrderTrackingScenarioUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<ThemeStore>(
      ThemeStore(getIt<SettingRepository>(), getIt<ErrorStore>()),
    );

    getIt.registerSingleton<LanguageStore>(
      LanguageStore(getIt<SettingRepository>(), getIt<ErrorStore>()),
    );

    getIt.registerSingleton<StockOperationsStore>(
      StockOperationsStore(getIt<StockOperationsRepository>()),
    );

    getIt.registerSingleton<InventoryAuditOutboundStore>(
      InventoryAuditOutboundStore(
        getIt<GetInventoryWarehousesUseCase>(),
        getIt<GetInventoryByWarehouseUseCase>(),
        getIt<SaveInventoryAuditSessionUseCase>(),
        getIt<GetInventoryAuditRecordsUseCase>(),
        getIt<SubmitInventoryOutboundUseCase>(),
        getIt<GetInventoryOutboundRecordsUseCase>(),
      ),
    );

    getIt.registerSingleton<PostPurchaseStore>(
      PostPurchaseStore(
        getIt<GetIssueListUseCase>(),
        getIt<GetOrderPoolUseCase>(),
        getIt<GetIssueDetailUseCase>(),
        getIt<CreateIssueUseCase>(),
        getIt<ExecuteIssueActionUseCase>(),
        getIt<UpdateIssueNotesUseCase>(),
        getIt<GetExchangeListUseCase>(),
        getIt<GetExchangeDetailUseCase>(),
        getIt<CreateExchangeFromIssueUseCase>(),
        getIt<ExecuteExchangeActionUseCase>(),
        getIt<UpdateExchangeNotesUseCase>(),
        getIt<GetRefundListUseCase>(),
        getIt<GetRefundDetailUseCase>(),
        getIt<CreateRefundFromIssueUseCase>(),
        getIt<ExecuteRefundActionUseCase>(),
        getIt<UpdateRefundNotesUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<user_mgmt.UserStore>(
      user_mgmt.UserStore(
        getIt<UserRepository>(),
        getIt<RoleRepository>(),
        getIt<AssignRoleToUserUseCase>(),
        getIt<GetAllUsersUseCase>(),
        getIt<GetUserByIdUseCase>(),
        getIt<CreateUserUseCase>(),
        getIt<UpdateUserUseCase>(),
        getIt<DeleteUserUseCase>(),
      ),
    );

    getIt.registerSingleton<RoleStore>(
      RoleStore(
        getIt<RoleRepository>(),
        getIt<CreateRoleUseCase>(),
        getIt<UpdateRoleUseCase>(),
        getIt<DeleteRoleUseCase>(),
        getIt<GetAllRolesUseCase>(),
        getIt<GetRoleByIdUseCase>(),
      ),
    );

    getIt.registerLazySingleton<SupplierStore>(
      () => SupplierStore(
        getIt<GetSuppliersUseCase>(),
        getIt<GetSupplierByIdUseCase>(),
        getIt<CreateSupplierUseCase>(),
        getIt<UpdateSupplierUseCase>(),
        getIt<DeleteSupplierUseCase>(),
      ),
    );

    getIt.registerLazySingleton<SupplierProductsStore>(
      () => SupplierProductsStore(
        getIt<GetSupplierProductsUseCase>(),
        getIt<AddProductToSupplierUseCase>(),
        getIt<UpdateProductSupplierLinkUseCase>(),
        getIt<RemoveProductFromSupplierUseCase>(),
        getIt<SearchProductsUseCase>(),
      ),
    );

    getIt.registerSingleton<CmsPageStore>(
      CmsPageStore(
        getIt<GetCmsPagesUseCase>(),
        getIt<GetCmsPageByIdUseCase>(),
        getIt<SaveCmsPageUseCase>(),
        getIt<DeleteCmsPageUseCase>(),
        getIt<PublishCmsPageUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<WebThemeStore>(
      WebThemeStore(
        getIt<GetWebThemesUseCase>(),
        getIt<GetWebThemeByIdUseCase>(),
        getIt<ApplyWebThemeUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<StoreSettingsStore>(
      StoreSettingsStore(
        getIt<GetStoreSettingsUseCase>(),
        getIt<SaveStoreSettingsUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerFactory<ProductDetailStore>(
      () => ProductDetailStore(
        getIt<StorefrontRepository>(),
        getIt<ErrorStore>(),
      ),
    );

    getIt.registerSingleton<FulfillmentStore>(
      FulfillmentStore(
        getIt<GetFulfillmentOrdersUseCase>(),
        getIt<GetFulfillmentOrderDetailUseCase>(),
        getIt<UpdateFulfillmentStatusUseCase>(),
        getIt<CreateOrLinkShipmentUseCase>(),
        getIt<GetOrderRoutingRecommendationUseCase>(),
        getIt<ApplyOrderRoutingRecommendationUseCase>(),
        getIt<GetShipmentTrackingUseCase>(),
        getIt<GetOrderShipmentsTrackingUseCase>(),
        getIt<GetShipmentLabelArtifactsUseCase>(),
        getIt<GetShipmentPrintJobsUseCase>(),
        getIt<CreateShipmentPrintJobUseCase>(),
        getIt<CreateShipmentPrintAttemptUseCase>(),
        getIt<ErrorStore>(),
      ),
    );

    // Product listing store:---------------------------------------------------
    getIt.registerSingleton<ListingFilters>(
      ListingFilters(getIt<StorefrontRepository>()),
    );

    // Cart and Wishlist stores:------------------------------------------------
    getIt.registerSingleton<WishlistStore>(
      WishlistStore(wishlistRepository: getIt<WishlistRepository>()),
    );

    getIt.registerSingleton<CartStore>(
      CartStore(
        cartRepository: getIt<CartRepository>(),
        couponRepository: getIt<CouponRepository>(),
        wishlistStore: getIt<WishlistStore>(),
      ),
    );

    // checkout:---------------------------------------------------------------
    getIt.registerSingleton<CheckoutStore>(
      CheckoutStore(
        getIt<GetShippingMethodsUseCase>(),
        getIt<GetPaymentMethodsUseCase>(),
        getIt<ValidateCouponUseCase>(),
        getIt<ParseAddressUseCase>(),
        getIt<CreateCheckoutOrderUseCase>(),
        getIt<ConfirmOrderUseCase>(),
        getIt<GetSavedAddressesUseCase>(),
        getIt<SaveAddressUseCase>(),
        getIt<DeleteAddressUseCase>(),
        getIt<ErrorStore>(),
        getIt<CartStore>(),
      ),
    );

    getIt.registerSingleton<ProductStore>(
      ProductStore(getIt<ProductManagementRepository>(), getIt<ErrorStore>()),
    );

    getIt.registerSingleton<ProductFormStore>(
      ProductFormStore(
        getIt<ProductManagementRepository>(),
        getIt<ErrorStore>(),
      ),
    );
  }
}
