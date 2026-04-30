import 'dart:async';

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
import 'package:mobile_ai_erp/domain/usecase/fulfillment/add_package_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_order_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/get_fulfillment_orders_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/update_fulfillment_status_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/update_package_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/fulfillment/update_picked_quantity_usecase.dart';
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
    getIt.registerSingleton<UpdatePickedQuantityUseCase>(
      UpdatePickedQuantityUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<AddPackageUseCase>(
      AddPackageUseCase(getIt<FulfillmentRepository>()),
    );
    getIt.registerSingleton<UpdatePackageUseCase>(
      UpdatePackageUseCase(getIt<FulfillmentRepository>()),
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
      SaveInventoryAuditSessionUseCase(getIt<InventoryAuditOutboundRepository>()),
    );
    getIt.registerSingleton<GetInventoryAuditRecordsUseCase>(
      GetInventoryAuditRecordsUseCase(getIt<InventoryAuditOutboundRepository>()),
    );
    getIt.registerSingleton<SubmitInventoryOutboundUseCase>(
      SubmitInventoryOutboundUseCase(getIt<InventoryAuditOutboundRepository>()),
    );
    getIt.registerSingleton<GetInventoryOutboundRecordsUseCase>(
      GetInventoryOutboundRecordsUseCase(getIt<InventoryAuditOutboundRepository>()),
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
  }
}
