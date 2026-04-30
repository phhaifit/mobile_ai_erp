class StorefrontEndpoints {
  StorefrontEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'STOREFRONT_API_BASE_URL',
    defaultValue: 'https://erp-api.jarvis.cx',
  );

  static const String tenantId = String.fromEnvironment(
    'STOREFRONT_TENANT_ID',
    defaultValue: 'a679f223-ea7a-4a97-8102-311ca2cac533',
  );

  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 30000;
}
