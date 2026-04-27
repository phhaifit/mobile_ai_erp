class StorefrontEndpoints {
  StorefrontEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'STOREFRONT_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5000',
  );

  static const String tenantId = String.fromEnvironment(
    'STOREFRONT_TENANT_ID',
    defaultValue: 'e02556be-d5f8-42ef-a40d-0924151881d5',
  );

  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 30000;
}
