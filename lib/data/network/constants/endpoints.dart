class Endpoints {
  Endpoints._();

  // ERP backend base url - override at build time:
  //   --dart-define=ERP_BASE_URL=https://erp-api.jarvis.cx
  static const String erpBaseUrl = String.fromEnvironment(
    'ERP_BASE_URL',
    defaultValue: 'https://erp-api.jarvis.cx',
  );

  // Tenant id sent via X-Tenant-Id header to ERP backend.
  // Override at build time:
  //   --dart-define=TENANT_ID=<uuid>
  static const String tenantId = String.fromEnvironment(
    'TENANT_ID',
    defaultValue: '00000000-0000-0000-0000-000000000000',
  );

  // Optional debug product id for direct PDP navigation.
  // Override at build time:
  //   --dart-define=PRODUCT_ID=<product-id>
  static const String debugProductId = String.fromEnvironment(
    'PRODUCT_ID',
    defaultValue: '',
  );

  // timeouts
  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 30000;

  // brand endpoints
  static const String brandsUrl = '/erp/brands';

  // category endpoints
  static const String categoriesUrl = '/erp/categories';

  // product endpoints
  static const String productsUrl = '/erp/products';

  static const String getPosts = "/posts";

  // auth endpoints
  static const String authStatus = "/auth/status";
  static const String authRefresh = "/auth/refresh";
  static const String authSignOut = "/auth/sign-out";
  static const String tenantsCreate = "/tenants";

  // customer auth endpoints
  static const String customerAuthRefresh = "/customer/auth/refresh";

  static const String stackAuthHost = 'api.stack-auth.com';
  static const String stackAuthAuthenticate = '/api/v1/auth/oauth/authorize/';
  static const String stackAuthToken =
      'https://$stackAuthHost/api/v1/auth/oauth/token';

  static const String storefront = "$erpBaseUrl/storefront";

  // cart
  static const String storefrontCart = "$storefront/cart";
  static const String storefrontCartSummary = "$storefront/cart/summary";
  static const String storefrontCartItems = "$storefront/cart/items";
  static const String storefrontCartCalculate = "$storefront/cart/calculate";
  static const String storefrontCartMerge = "$storefront/cart/merge";

  static String storefrontCartItemById(String cartItemId) =>
      "$storefrontCartItems/$cartItemId";

  // wishlist
  static const String storefrontWishlist = "$storefront/wishlist";
  static const String storefrontWishlistSummary =
      "$storefront/wishlist/summary";
  static const String storefrontWishlistItems = "$storefront/wishlist/items";
  static const String storefrontWishlistMerge = "$storefront/wishlist/merge";

  static String storefrontWishlistItemById(String wishlistItemId) =>
      "$storefrontWishlistItems/$wishlistItemId";

  // coupon
  static const String storefrontCoupons = "$storefront/coupons";
  static const String storefrontCouponsValidate =
      "$storefront/coupons/validate";

  // addresses
  static const String storefrontAddresses = "$storefront/addresses";
  static String storefrontAddressById(String id) =>
      "$storefront/addresses/$id";
  static String storefrontAddressSetDefault(String id) =>
      "$storefront/addresses/$id/default";

  // checkout
  static const String storefrontCheckout = "$storefront/checkout";

  // storefront orders
  static const String storefrontOrders = "$storefront/orders";
  static String storefrontOrderById(String id) =>
      "$storefront/orders/$id";

  // storefront payments
  static const String storefrontPayments = "$storefront/payments";
  static String storefrontPaymentById(String id) =>
      "$storefront/payments/$id";

  // web builder - store settings
  static const String storeSettings = "/store-settings";

  // web builder - cms pages
  static const String cmsPages = "/cms-pages";
  static String cmsPageById(String id) => "/cms-pages/$id";
  static String cmsPagePublish(String id) => "/cms-pages/$id/publish";

  // web builder - themes
  static const String themes = "/themes";
  static const String activeTheme = "/themes/active";


  // Customer auth endpoints
  static String getTenantBySubdomain(String subdomain) => "/tenants/by-subdomain/$subdomain";
  static String customerSignUp = "/customer/auth/sign-up";
  static String customerSignIn = "/customer/auth/sign-in";
  static String customerRefreshToken = "/customer/auth/refresh";
  static String customerGetGoogleOAuthUrl = "/customer/auth/google/oauth";
  static String customerSignOut = "/customer/auth/sign-out";
  static String customerAuthGetSessions = "/customer/auth/sessions";
  static String customerSendMagicLink = "/customer/auth/magic-link";
  static String customerConfirmMagicLink = "/customer/auth/magic-link/confirm";
  static String customerVerifyEmail = "/customer/auth/verify-email";
  static String customerCurrentProfile = "/customer/profile";

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

  // order endpoints
  static const String orders = "/erp/orders";
  static String orderDetail(String id) => "/erp/orders/$id";
  static String orderStatus(String id) => "/erp/orders/$id/status";
  static String orderShipment(String id) => "/orders/$id/shipment";
  static String orderShipmentTracking(String id) =>
      "/orders/$id/shipment/tracking";
  static String orderShipmentsTracking(String id) =>
      "/orders/$id/shipments/tracking";
  static String orderShipmentLabels(String orderId, String shipmentId) =>
      "/orders/$orderId/shipments/$shipmentId/labels";
  static String orderShipmentPrintJobs(String orderId, String shipmentId) =>
      "/orders/$orderId/shipments/$shipmentId/print-jobs";
  static String orderShipmentPrintAttempts(
    String orderId,
    String shipmentId,
    String printJobId,
  ) => "/orders/$orderId/shipments/$shipmentId/print-jobs/$printJobId/attempts";

  // storefront - products
  static const String storefrontProducts = "/storefront/products";
  static String storefrontProductById(String id) => "/storefront/products/$id";
  static String storefrontBrandProducts(String brandKey) =>
      "/storefront/products/brands/$brandKey/products";
  static String storefrontCategoryByKey(String categoryKey) =>
      "/storefront/categories/$categoryKey";

  static String storefrontAccountProfile = "/storefront/account/profile";
}
