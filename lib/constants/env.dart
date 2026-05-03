class Env {
  Env._();
  // DO NOT COMMIT
  static const String stackAuthClientId = String.fromEnvironment("STACK_AUTH_PROJECT_ID");
  static const String stackAuthClientSecret = String.fromEnvironment("STACK_AUTH_PCK");
  static const bool isCustomerApp = bool.fromEnvironment("IS_CUSTOMER_APP", defaultValue: false);
}