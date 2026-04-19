import 'dart:async';

import 'package:mobile_ai_erp/domain/repository/account/customer_repository.dart';
import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';
import 'package:mobile_ai_erp/domain/repository/post/post_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/role_repository.dart';
import 'package:mobile_ai_erp/domain/repository/order_tracking/order_tracking_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/domain/repository/inventory_audit_outbound/inventory_audit_outbound_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/store_settings_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/web_theme_repository.dart';
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
import 'package:mobile_ai_erp/domain/usecase/user/assign_role_to_user_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/create_role_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/login_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/update_role_usercase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/apply_web_theme_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/delete_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_cms_page_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_cms_pages_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_store_settings_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_web_theme_by_id_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/get_web_themes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/save_cms_page_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/save_store_settings_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/customer_login_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/customer_register_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/customer_forgot_password_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/customer/get_profile_usecase.dart';

import '../../../di/service_locator.dart';

class UseCaseModule {
  static Future<void> configureUseCaseModuleInjection() async {
    // user:--------------------------------------------------------------------
    getIt.registerSingleton<IsLoggedInUseCase>(
      IsLoggedInUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<SaveLoginStatusUseCase>(
      SaveLoginStatusUseCase(getIt<UserRepository>()),
    );
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
  }
}
