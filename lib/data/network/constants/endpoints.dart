class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = "http://192.168.1.199:10000";

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  // booking endpoints
  static const String getPosts = baseUrl + "/posts";

  // auth endpoints
  static const String authStatus = baseUrl + "/auth/status";
  static const String authRefresh = baseUrl + "/auth/refresh";
  static const String authSignOut = baseUrl + "/auth/sign-out";
  static const String tenantsCreate = baseUrl + "/tenants";

  static const String stackAuthHost = 'api.stack-auth.com';
  static const String stackAuthAuthenticate = '/api/v1/auth/oauth/authorize/';
  static const String stackAuthToken = 'https://$stackAuthHost/api/v1/auth/oauth/token';
}