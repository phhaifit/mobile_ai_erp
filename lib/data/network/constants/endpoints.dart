class Endpoints {
  Endpoints._();

  // base url for mock API
  static const String baseUrl = "http://jsonplaceholder.typicode.com";

  // base url for backend API
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: "http://127.0.0.1:5002",
  );

  static const String erpSecretKey = String.fromEnvironment(
    'ERP_SECRET_KEY',
    defaultValue: '',
  );

  static const String erpTenantId = String.fromEnvironment(
    'ERP_TENANT_ID',
    defaultValue: '',
  );

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  // booking endpoints
  static const String getPosts = baseUrl + "/posts";
}
