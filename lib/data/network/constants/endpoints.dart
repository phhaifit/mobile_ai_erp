class Endpoints {
  Endpoints._();

  // ERP backend base url - override at build time:
  //   --dart-define=ERP_BASE_URL=https://erp-api.jarvis.cx/api
  static const String erpBaseUrl = String.fromEnvironment(
    'ERP_BASE_URL',
    defaultValue: 'https://erp-api.jarvis.cx/api',
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

  // customer segments
  static const String customerSegments = '/erp/customer-segments';
  static String customerSegmentById(String id) => '/erp/customer-segments/$id';
  static String customerSegmentMembers(String id) =>
      '/erp/customer-segments/$id/members';

  // customers
  static const String customers = '/erp/customers';
  static String customerById(String id) => '/erp/customers/$id';
  static String customerStatus(String id) => '/erp/customers/$id/status';
  static String customerAddresses(String id) => '/erp/customers/$id/addresses';
  static String customerAddressById(String customerId, String addressId) =>
      '/erp/customers/$customerId/addresses/$addressId';
  static String customerAddressDefault(String customerId, String addressId) =>
      '/erp/customers/$customerId/addresses/$addressId/default';
  static String customerTransactions(String id) =>
      '/erp/customers/$id/transactions';
}
