class Endpoints {
  Endpoints._();

  // ERP backend base url - override at build time:
  //   --dart-define=ERP_BASE_URL=https://erp-api.jarvis.cx/api
  static const String erpBaseUrl = String.fromEnvironment(
    'ERP_BASE_URL',
    defaultValue: 'https://erp-api.jarvis.cx',
  );

  // Tenant id sent via X-Tenant-Id header to ERP backend.
  // Override at build time:
  //   --dart-define=TENANT_ID=<uuid>
  static const String tenantId = String.fromEnvironment(
    'TENANT_ID',
    defaultValue: '00000000-0000-0000-0000-000000000000',
  );

  // timeouts
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 30000;

  static const String getPosts = "/posts";

  // auth endpoints
  static const String authStatus = "/auth/status";
  static const String authRefresh = "/auth/refresh";
  static const String authSignOut = "/auth/sign-out";
  static const String tenantsCreate = "/tenants";

  static const String stackAuthHost = 'api.stack-auth.com';
  static const String stackAuthAuthenticate = '/api/v1/auth/oauth/authorize/';
  static const String stackAuthToken = 'https://$stackAuthHost/api/v1/auth/oauth/token';

  // web builder - store settings
  static const String storeSettings = "/store-settings";

  // web builder - cms pages
  static const String cmsPages = "/cms-pages";
  static String cmsPageById(String id) => "/cms-pages/$id";
  static String cmsPagePublish(String id) => "/cms-pages/$id/publish";

  // web builder - themes
  static const String themes = "/themes";
  static const String activeTheme = "/themes/active";

  // order endpoints
  static const String orders = "/erp/orders";
  static String orderDetail(String id) => "/erp/orders/$id";
  static String orderStatus(String id) => "/erp/orders/$id/status";
  static String orderShipment(String id) => "/orders/$id/shipment";
  static String orderShipmentTracking(String id) =>
      "/orders/$id/shipment/tracking";
  static String orderShipmentsTracking(String id) =>
      "/orders/$id/shipments/tracking";
  static String orderShipmentLabels(String orderId, String shipmentId) =>
      "/orders/$orderId/shipments/$shipmentId/labels";
  static String orderShipmentPrintJobs(String orderId, String shipmentId) =>
      "/orders/$orderId/shipments/$shipmentId/print-jobs";
  static String orderShipmentPrintAttempts(
    String orderId,
    String shipmentId,
    String printJobId,
  ) => "/orders/$orderId/shipments/$shipmentId/print-jobs/$printJobId/attempts";
}
