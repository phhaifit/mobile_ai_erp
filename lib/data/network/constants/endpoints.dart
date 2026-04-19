class Endpoints {
  Endpoints._();

  // base url - TODO: Load from environment
  static const String baseUrl = "http://localhost:5000"; // Replace with actual API base URL
  static const String customerBaseUrl = "$baseUrl/customer";

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  // booking endpoints
  static const String getPosts = "http://jsonplaceholder.typicode.com/posts";

  // Customer auth endpoints
  static const String customerLogin = "$customerBaseUrl/auth/sign-in";
  static const String customerRegister = "$customerBaseUrl/auth/sign-up";
  static const String customerForgotPassword = "$customerBaseUrl/auth/magic-link";

  // Customer profile endpoints
  static const String customerProfile = "$customerBaseUrl/profile";
  static const String customerLoyalty = "$customerBaseUrl/loyalty";

  // Address endpoints
  static const String customerAddresses = "$customerBaseUrl/addresses";

  // Order endpoints
  static const String customerOrders = "$customerBaseUrl/orders";
}