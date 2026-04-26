class Endpoints {
  Endpoints._();

  // Base URLs
  static const String baseUrl = "http://localhost:5000"; // TODO: Load from environment
  
  // Create distinct bases for Auth vs. Account Portal
  static const String customerAuthUrl = "$baseUrl/customer/auth";
  static const String storefrontAccountUrl = "$baseUrl/storefront";

  // Timeouts
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 30000;

  // ─── CUSTOMER AUTHENTICATION ──────────────────────────────────────────
  static const String customerLogin = "$customerAuthUrl/sign-in";
  static const String customerRegister = "$customerAuthUrl/sign-up";
  static const String customerForgotPassword = "$customerAuthUrl/magic-link";

  // ─── STOREFRONT ACCOUNT PORTAL (Feature 15) ─────────────────────────
  // These now correctly point to the secure controller we just built
  static const String customerProfile = "$storefrontAccountUrl/account/profile";
  static const String customerAddresses = "$storefrontAccountUrl/addresses";
  static const String customerOrders = "$storefrontAccountUrl/orders";

  // ─── UNUSED ENDPOINTS ──────────────────────────────────────────────
  static const String customerLoyalty = "$storefrontAccountUrl/loyalty";
  // Why: We haven't built this in the backend yet.

  // booking endpoints
  static const String getPosts = baseUrl + "/posts";
}