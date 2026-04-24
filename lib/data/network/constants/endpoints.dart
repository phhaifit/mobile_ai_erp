class Endpoints {
  Endpoints._();

  // base url (legacy - sample posts API)
  static const String baseUrl = "http://jsonplaceholder.typicode.com";

  // ERP backend base url - override at build time:
  //   --dart-define=ERP_BASE_URL=http://10.0.2.2:3000
  static const String erpBaseUrl = String.fromEnvironment(
    'ERP_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
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

  // legacy posts endpoint
  static const String getPosts = baseUrl + "/posts";

  // web builder - store settings
  static const String storeSettings = "/store-settings";

  // web builder - cms pages
  static const String cmsPages = "/cms-pages";
  static String cmsPageById(String id) => "/cms-pages/$id";
  static String cmsPagePublish(String id) => "/cms-pages/$id/publish";

  // web builder - themes
  static const String themes = "/themes";
  static const String activeTheme = "/themes/active";
}
