class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://jsonplaceholder.typicode.com');

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  // booking endpoints
  static const String getPosts = baseUrl + "/posts";

  // brand endpoints
  static const String brandsUrl = 'http://127.0.0.1:12345/erp/brands';//'$baseUrl/erp/brands';

  // category endpoints
  static const String categoriesUrl = '$baseUrl/erp/categories';
}