import 'dart:async';

import 'package:mobile_ai_erp/domain/repository/fulfillment/fulfillment_repository.dart';
import 'package:mobile_ai_erp/domain/repository/post/post_repository.dart';
import 'package:mobile_ai_erp/domain/repository/post_purchase/post_purchase_repository.dart';
import 'package:mobile_ai_erp/domain/repository/order_tracking/order_tracking_repository.dart';
import 'package:mobile_ai_erp/domain/repository/user/user_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/cms_page_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/store_settings_repository.dart';
import 'package:mobile_ai_erp/domain/repository/web_builder/web_theme_repository.dart';
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
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_issue_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_issue_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_return_detail_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/get_return_list_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_issue_status_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_issue_notes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/link_issue_to_return_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_return_notes_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/convert_exchange_to_refund_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/post_purchase/update_return_status_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/login_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/apply_web_theme_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/web_builder/delete_cms_page_usecase.dart';
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
    getIt.registerSingleton<IsLoggedInUseCase>(
      IsLoggedInUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<SaveLoginStatusUseCase>(
      SaveLoginStatusUseCase(getIt<UserRepository>()),
    );
    getIt.registerSingleton<LoginUseCase>(
      LoginUseCase(getIt<UserRepository>()),
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
    getIt.registerSingleton<GetIssueDetailUseCase>(
      GetIssueDetailUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<UpdateIssueStatusUseCase>(
      UpdateIssueStatusUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<UpdateIssueNotesUseCase>(
      UpdateIssueNotesUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<LinkIssueToReturnUseCase>(
      LinkIssueToReturnUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<GetReturnListUseCase>(
      GetReturnListUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<GetReturnDetailUseCase>(
      GetReturnDetailUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<UpdateReturnStatusUseCase>(
      UpdateReturnStatusUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<UpdateReturnNotesUseCase>(
      UpdateReturnNotesUseCase(getIt<PostPurchaseRepository>()),
    );
    getIt.registerSingleton<ConvertExchangeToRefundUseCase>(
      ConvertExchangeToRefundUseCase(getIt<PostPurchaseRepository>()),
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
  }
}
