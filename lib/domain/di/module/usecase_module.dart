import 'dart:async';

import 'package:mobile_ai_erp/domain/repository/storefront_account/order_repository.dart';
import 'package:mobile_ai_erp/domain/repository/storefront_account/customer_repository.dart';
import 'package:mobile_ai_erp/domain/repository/checkout/checkout_repository.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';
import 'package:mobile_ai_erp/domain/repository/post/post_repository.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/repository/order_tracking/order_tracking_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/auth_repository.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/store_settings_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/web_theme_repository.dart';
import 'package:mobile_ai_erp/domain/repository/supplier/supplier_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/supplier/supplier_usecases.dart';
import 'package:mobile_ai_erp/domain/repository/product_metadata/product_metadata_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/checkout_usecases.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/get_payment_methods_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/get_shipping_methods_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/validate_coupon_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_audit_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_by_warehouse_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_outbound_records_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/get_inventory_warehouses_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/save_inventory_audit_session_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/inventory_audit_outbound/submit_inventory_outbound_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/order_tracking/find_order_tracking_scenario_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/order_tracking/get_order_tracking_scenarios_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/create_or_link_shipment_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/apply_order_routing_recommendation_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/create_shipment_print_attempt_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/create_shipment_print_job_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_order_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_orders_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_order_routing_recommendation_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_shipment_label_artifacts_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_order_shipments_tracking_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_shipment_print_jobs_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_shipment_tracking_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/update_fulfillment_status_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/delete_post_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/find_post_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/get_post_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/insert_post_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post/udpate_post_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/create_exchange_from_issue_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/create_issue_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/create_refund_from_issue_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/execute_exchange_action_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/execute_issue_action_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/execute_refund_action_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_exchange_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_exchange_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_issue_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_issue_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_order_pool_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_refund_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_refund_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_issue_notes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_exchange_notes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_refund_notes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/assign_role_to_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/create_role_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/delete_role_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_all_roles_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/get_role_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/login_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/update_role_usercase.dart';
import 'package:mobile_ai_erp/domain/usecase/auth/create_tenant_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/apply_web_theme_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/delete_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/publish_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_cms_page_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_cms_pages_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_store_settings_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_web_theme_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_web_themes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/save_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/save_store_settings_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/storefront_customer/customer_login_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/storefront_customer/customer_register_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/storefront_customer/customer_forgot_password_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/storefront_customer/get_profile_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/storefront_order/get_order_details_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/storefront_order/get_order_history_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/storefront_order/reorder_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/storefront_order/submit_return_request_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/storefront_order/cancel_order_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/storefront_order/confirm_order_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/storefront_customer/update_profile_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/loyalty_ledgers/get_loyalty_balance_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/loyalty_ledgers/get_loyalty_history_usecase.dart';
import 'package:mobile_ai_erp/domain/repository/storefront_account/loyalty_ledger_repository.dart';
import 'package:mobile_ai_erp/domain/repository/customer/customer_repository.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_customers_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_customer_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/save_customer_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/delete_customer_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_customer_groups_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/save_customer_group_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/delete_customer_group_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_customer_addresses_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/save_customer_address_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/delete_customer_address_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/set_default_address_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_customer_transactions_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_segment_members_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/add_segment_members_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/remove_segment_members_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/get_brands_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/get_brand_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/create_brand_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/update_brand_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/delete_brand_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/get_brand_image_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/upload_brand_image_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/brands/delete_brand_image_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/get_tags_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/get_tag_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/create_tag_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/update_tag_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/tags/delete_tag_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/categories/get_categories_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/categories/get_category_tree_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/categories/get_category_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/categories/create_category_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/categories/update_category_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/categories/delete_category_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/get_attribute_sets_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/get_attribute_set_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/get_all_attribute_values_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/create_attribute_set_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/update_attribute_set_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/delete_attribute_set_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/get_attribute_values_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/create_attribute_value_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/update_attribute_value_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/product_metadata/attribute_sets/delete_attribute_value_usecase.dart';

import '../../../di/service_locator.dart';

class UseCaseModule {
  static Future<void> configureUseCaseModuleInjection() async {
    // user:--------------------------------------------------------------------
    getIt.registerSingleton<LoginUseCase>(
      LoginUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<AssignRoleToUserUseCase>(
      AssignRoleToUserUseCase(getIt<UserRepository>()),
    );

    getIt.registerSingleton<CreateRoleUseCase>(
      CreateRoleUseCase(getIt<RoleRepository>()),
    );

    getIt.registerSingleton<UpdateRoleUseCase>(
      UpdateRoleUseCase(getIt<RoleRepository>()),
    );

    getIt.registerSingleton<DeleteRoleUseCase>(
      DeleteRoleUseCase(getIt<RoleRepository>()),
    );

    getIt.registerSingleton<GetAllRolesUseCase>(
      GetAllRolesUseCase(getIt<RoleRepository>()),
    );

    getIt.registerSingleton<GetRoleByIdUseCase>(
      GetRoleByIdUseCase(getIt<RoleRepository>()),
    );
    // auth:--------------------------------------------------------------------
    getIt.registerSingleton<CreateTenantUseCase>(
      CreateTenantUseCase(getIt<AuthRepository>()),
    );

    // post:--------------------------------------------------------------------
    getIt.registerSingleton<GetPostUseCase>(
      GetPostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<FindPostByIdUseCase>(
      FindPostByIdUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<InsertPostUseCase>(
      InsertPostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<UpdatePostUseCase>(
      UpdatePostUseCase(getIt<PostRepository>()),
    );
    getIt.registerSingleton<DeletePostUseCase>(
      DeletePostUseCase(getIt<PostRepository>()),
    );

    // post_purchase:----------------------------------------------------------
    getIt.registerSingleton<GetIssueListUseCase>(
      GetIssueListUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<GetOrderPoolUseCase>(
      GetOrderPoolUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<GetIssueDetailUseCase>(
      GetIssueDetailUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<CreateIssueUseCase>(
      CreateIssueUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<ExecuteIssueActionUseCase>(
      ExecuteIssueActionUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<UpdateIssueNotesUseCase>(
      UpdateIssueNotesUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<GetExchangeListUseCase>(
      GetExchangeListUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<GetExchangeDetailUseCase>(
      GetExchangeDetailUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<CreateExchangeFromIssueUseCase>(
      CreateExchangeFromIssueUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<ExecuteExchangeActionUseCase>(
      ExecuteExchangeActionUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<UpdateExchangeNotesUseCase>(
      UpdateExchangeNotesUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<GetRefundListUseCase>(
      GetRefundListUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<GetRefundDetailUseCase>(
      GetRefundDetailUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<CreateRefundFromIssueUseCase>(
      CreateRefundFromIssueUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<ExecuteRefundActionUseCase>(
      ExecuteRefundActionUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<UpdateRefundNotesUseCase>(
      UpdateRefundNotesUseCase(getIt<PostPurchaseRepository>()),
    );

    // web_builder:--------------------------------------------------------------
    getIt.registerSingleton<GetCmsPagesUseCase>(
      GetCmsPagesUseCase(getIt<CmsPageRepository>()),
    );
    getIt.registerSingleton<GetCmsPageByIdUseCase>(
      GetCmsPageByIdUseCase(getIt<CmsPageRepository>()),
    );
    getIt.registerSingleton<SaveCmsPageUseCase>(
      SaveCmsPageUseCase(getIt<CmsPageRepository>()),
    );
    getIt.registerSingleton<DeleteCmsPageUseCase>(
      DeleteCmsPageUseCase(getIt<CmsPageRepository>()),
    );
    getIt.registerSingleton<PublishCmsPageUseCase>(
      PublishCmsPageUseCase(getIt<CmsPageRepository>()),
    );
    getIt.registerSingleton<GetWebThemesUseCase>(
      GetWebThemesUseCase(getIt<WebThemeRepository>()),
    );
    getIt.registerSingleton<GetWebThemeByIdUseCase>(
      GetWebThemeByIdUseCase(getIt<WebThemeRepository>()),
    );
    getIt.registerSingleton<ApplyWebThemeUseCase>(
      ApplyWebThemeUseCase(getIt<WebThemeRepository>()),
    );
    getIt.registerSingleton<GetStoreSettingsUseCase>(
      GetStoreSettingsUseCase(getIt<StoreSettingsRepository>()),
    );
    getIt.registerSingleton<SaveStoreSettingsUseCase>(
      SaveStoreSettingsUseCase(getIt<StoreSettingsRepository>()),
    );
    // fulfillment:-------------------------------------------------------------
    getIt.registerSingleton<GetFulfillmentOrdersUseCase>(
      GetFulfillmentOrdersUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<GetFulfillmentOrderDetailUseCase>(
      GetFulfillmentOrderDetailUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<UpdateFulfillmentStatusUseCase>(
      UpdateFulfillmentStatusUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<CreateOrLinkShipmentUseCase>(
      CreateOrLinkShipmentUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<GetOrderRoutingRecommendationUseCase>(
      GetOrderRoutingRecommendationUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<ApplyOrderRoutingRecommendationUseCase>(
      ApplyOrderRoutingRecommendationUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<GetShipmentTrackingUseCase>(
      GetShipmentTrackingUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<GetOrderShipmentsTrackingUseCase>(
      GetOrderShipmentsTrackingUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<GetShipmentLabelArtifactsUseCase>(
      GetShipmentLabelArtifactsUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<GetShipmentPrintJobsUseCase>(
      GetShipmentPrintJobsUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<CreateShipmentPrintJobUseCase>(
      CreateShipmentPrintJobUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<CreateShipmentPrintAttemptUseCase>(
      CreateShipmentPrintAttemptUseCase(getIt<FulfillmentRepository>()),
    );

    // order tracking:----------------------------------------------------------
    getIt.registerSingleton<GetOrderTrackingScenariosUseCase>(
      GetOrderTrackingScenariosUseCase(getIt<OrderTrackingRepository>()),
    );
    getIt.registerSingleton<FindOrderTrackingScenarioUseCase>(
      FindOrderTrackingScenarioUseCase(getIt<OrderTrackingRepository>()),
    );

    // checkout:---------------------------------------------------------------
    getIt.registerSingleton<GetShippingMethodsUseCase>(
      GetShippingMethodsUseCase(getIt<CheckoutRepository>()),
    );
    getIt.registerSingleton<GetPaymentMethodsUseCase>(
      GetPaymentMethodsUseCase(getIt<CheckoutRepository>()),
    );
    getIt.registerSingleton<ValidateCouponUseCase>(
      ValidateCouponUseCase(getIt<CheckoutRepository>()),
    );
    getIt.registerSingleton<ValidateAddressUseCase>(
      ValidateAddressUseCase(getIt<CheckoutRepository>()),
    );
    getIt.registerSingleton<ParseAddressUseCase>(
      ParseAddressUseCase(getIt<CheckoutRepository>()),
    );
    getIt.registerSingleton<CreateCheckoutOrderUseCase>(
      CreateCheckoutOrderUseCase(getIt<CheckoutRepository>()),
    );
    getIt.registerSingleton<GetCheckoutOrderUseCase>(
      GetCheckoutOrderUseCase(getIt<CheckoutRepository>()),
    );
    getIt.registerSingleton<UpdateCheckoutOrderUseCase>(
      UpdateCheckoutOrderUseCase(getIt<CheckoutRepository>()),
    );
    getIt.registerSingleton<ConfirmOrderUseCase>(
      ConfirmOrderUseCase(getIt<CheckoutRepository>()),
    );
    getIt.registerSingleton<GetSavedAddressesUseCase>(
      GetSavedAddressesUseCase(getIt<CheckoutRepository>()),
    );
    getIt.registerSingleton<SaveAddressUseCase>(
      SaveAddressUseCase(getIt<CheckoutRepository>()),
    );
    getIt.registerSingleton<DeleteAddressUseCase>(
      DeleteAddressUseCase(getIt<CheckoutRepository>()),
    );

    // inventory_audit_outbound:-----------------------------------------------
    getIt.registerSingleton<GetInventoryWarehousesUseCase>(
      GetInventoryWarehousesUseCase(getIt<InventoryAuditOutboundRepository>()),
    );
    getIt.registerSingleton<GetInventoryByWarehouseUseCase>(
      GetInventoryByWarehouseUseCase(getIt<InventoryAuditOutboundRepository>()),
    );
    getIt.registerSingleton<SaveInventoryAuditSessionUseCase>(
      SaveInventoryAuditSessionUseCase(
        getIt<InventoryAuditOutboundRepository>(),
      ),
    );
    getIt.registerSingleton<GetInventoryAuditRecordsUseCase>(
      GetInventoryAuditRecordsUseCase(
        getIt<InventoryAuditOutboundRepository>(),
      ),
    );
    getIt.registerSingleton<SubmitInventoryOutboundUseCase>(
      SubmitInventoryOutboundUseCase(getIt<InventoryAuditOutboundRepository>()),
    );
    getIt.registerSingleton<GetInventoryOutboundRecordsUseCase>(
      GetInventoryOutboundRecordsUseCase(
        getIt<InventoryAuditOutboundRepository>(),
      ),
    );

    // supplier:-------------------------------------------------------------
    getIt.registerSingleton<GetSuppliersUseCase>(
      GetSuppliersUseCase(getIt<SupplierRepository>()),
    );
    getIt.registerSingleton<GetSupplierByIdUseCase>(
      GetSupplierByIdUseCase(getIt<SupplierRepository>()),
    );
    getIt.registerSingleton<CreateSupplierUseCase>(
      CreateSupplierUseCase(getIt<SupplierRepository>()),
    );
    getIt.registerSingleton<UpdateSupplierUseCase>(
      UpdateSupplierUseCase(getIt<SupplierRepository>()),
    );
    getIt.registerSingleton<DeleteSupplierUseCase>(
      DeleteSupplierUseCase(getIt<SupplierRepository>()),
    );
    getIt.registerSingleton<GetSupplierProductsUseCase>(
      GetSupplierProductsUseCase(getIt<SupplierRepository>()),
    );
    getIt.registerSingleton<AddProductToSupplierUseCase>(
      AddProductToSupplierUseCase(getIt<SupplierRepository>()),
    );
    getIt.registerSingleton<UpdateProductSupplierLinkUseCase>(
      UpdateProductSupplierLinkUseCase(getIt<SupplierRepository>()),
    );
    getIt.registerSingleton<RemoveProductFromSupplierUseCase>(
      RemoveProductFromSupplierUseCase(getIt<SupplierRepository>()),
    );
    getIt.registerSingleton<SearchProductsUseCase>(
      SearchProductsUseCase(getIt<SupplierRepository>()),
    );

    // customer:---------------------------------------------------------------
    getIt.registerSingleton<GetCustomersUseCase>(
      GetCustomersUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<GetCustomerDetailUseCase>(
      GetCustomerDetailUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<SaveCustomerUseCase>(
      SaveCustomerUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<DeleteCustomerUseCase>(
      DeleteCustomerUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<GetCustomerGroupsUseCase>(
      GetCustomerGroupsUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<SaveCustomerGroupUseCase>(
      SaveCustomerGroupUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<DeleteCustomerGroupUseCase>(
      DeleteCustomerGroupUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<GetCustomerAddressesUseCase>(
      GetCustomerAddressesUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<SaveCustomerAddressUseCase>(
      SaveCustomerAddressUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<DeleteCustomerAddressUseCase>(
      DeleteCustomerAddressUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<SetDefaultAddressUseCase>(
      SetDefaultAddressUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<GetCustomerTransactionsUseCase>(
      GetCustomerTransactionsUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<GetSegmentMembersUseCase>(
      GetSegmentMembersUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<AddSegmentMembersUseCase>(
      AddSegmentMembersUseCase(getIt<CustomerRepository>()),
    );
    getIt.registerSingleton<RemoveSegmentMembersUseCase>(
      RemoveSegmentMembersUseCase(getIt<CustomerRepository>()),
    );

    // customer account:-------------------------------------------------------
    getIt.registerSingleton<CustomerLoginUseCase>(
      CustomerLoginUseCase(getIt<AccountCustomerRepository>()),
    );
    getIt.registerSingleton<CustomerRegisterUseCase>(
      CustomerRegisterUseCase(getIt<AccountCustomerRepository>()),
    );
    getIt.registerSingleton<CustomerForgotPasswordUseCase>(
      CustomerForgotPasswordUseCase(getIt<AccountCustomerRepository>()),
    );
    getIt.registerSingleton<GetProfileUseCase>(
      GetProfileUseCase(getIt<AccountCustomerRepository>()),
    );

    getIt.registerSingleton<UpdateProfileUseCase>(
      UpdateProfileUseCase(getIt<AccountCustomerRepository>()),
    );

    // Customer order:-------------------------------------------------------

    getIt.registerSingleton<GetOrderHistoryUseCase>(
      GetOrderHistoryUseCase(getIt<StorefrontOrderRepository>()),
    );
    getIt.registerSingleton<GetOrderDetailsUseCase>(
      GetOrderDetailsUseCase(getIt<StorefrontOrderRepository>()),
    );
    getIt.registerSingleton<CancelOrderUseCase>(
      CancelOrderUseCase(getIt<StorefrontOrderRepository>()),
    );
    getIt.registerSingleton<SubmitReturnRequestUseCase>(
      SubmitReturnRequestUseCase(getIt<StorefrontOrderRepository>()),
    );
    getIt.registerSingleton<ReorderUseCase>(
      ReorderUseCase(getIt<StorefrontOrderRepository>()),
    );
    getIt.registerSingleton<ConfirmOrderUsecase>(
      ConfirmOrderUsecase(getIt<StorefrontOrderRepository>()),
    );

    // loyalty ledger:-------------------------------------------------------
    getIt.registerSingleton<GetLoyaltyHistoryUseCase>(
      GetLoyaltyHistoryUseCase(getIt<LoyaltyLedgerRepository>()),
    );
    getIt.registerSingleton<GetLoyaltyBalanceUseCase>(
      GetLoyaltyBalanceUseCase(getIt<LoyaltyLedgerRepository>()),
    );
    // product_metadata:-------------------------------------------------------
    // brands
    getIt.registerSingleton<GetBrandsUseCase>(
      GetBrandsUseCase(getIt<ProductMetadataRepository>()),
    );

    getIt.registerSingleton<GetBrandByIdUseCase>(
      GetBrandByIdUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<CreateBrandUseCase>(
      CreateBrandUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<UpdateBrandUseCase>(
      UpdateBrandUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<DeleteBrandUseCase>(
      DeleteBrandUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<GetBrandImageUseCase>(
      GetBrandImageUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<UploadBrandImageUseCase>(
      UploadBrandImageUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<DeleteBrandImageUseCase>(
      DeleteBrandImageUseCase(getIt<ProductMetadataRepository>()),
    );

    // tags
    getIt.registerSingleton<GetTagsUseCase>(
      GetTagsUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<GetTagByIdUseCase>(
      GetTagByIdUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<CreateTagUseCase>(
      CreateTagUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<UpdateTagUseCase>(
      UpdateTagUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<DeleteTagUseCase>(
      DeleteTagUseCase(getIt<ProductMetadataRepository>()),
    );

    // categories
    getIt.registerSingleton<GetCategoriesUseCase>(
      GetCategoriesUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<GetCategoryTreeUseCase>(
      GetCategoryTreeUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<GetCategoryByIdUseCase>(
      GetCategoryByIdUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<CreateCategoryUseCase>(
      CreateCategoryUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<UpdateCategoryUseCase>(
      UpdateCategoryUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<DeleteCategoryUseCase>(
      DeleteCategoryUseCase(getIt<ProductMetadataRepository>()),
    );

    // attribute sets
    getIt.registerSingleton<GetAttributeSetsUseCase>(
      GetAttributeSetsUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<GetAttributeSetByIdUseCase>(
      GetAttributeSetByIdUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<GetAllAttributeValuesUseCase>(
      GetAllAttributeValuesUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<CreateAttributeSetUseCase>(
      CreateAttributeSetUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<UpdateAttributeSetUseCase>(
      UpdateAttributeSetUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<DeleteAttributeSetUseCase>(
      DeleteAttributeSetUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<GetAttributeValuesUseCase>(
      GetAttributeValuesUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<CreateAttributeValueUseCase>(
      CreateAttributeValueUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<UpdateAttributeValueUseCase>(
      UpdateAttributeValueUseCase(getIt<ProductMetadataRepository>()),
    );
    getIt.registerSingleton<DeleteAttributeValueUseCase>(
      DeleteAttributeValueUseCase(getIt<ProductMetadataRepository>()),
    );
  }
}
