class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = "http://jsonplaceholder.typicode.com";

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  // booking endpoints
  static const String getPosts = baseUrl + "/posts";

  static const String storefront = "$baseUrl/storefront";

  // cart
  static const String storefrontCart = "$storefront/cart";
  static const String storefrontCartSummary = "$storefront/cart/summary";
  static const String storefrontCartItems = "$storefront/cart/items";
  static const String storefrontCartCalculate = "$storefront/cart/calculate";
  static const String storefrontCartMerge = "$storefront/cart/merge";

  // wishlist
  static const String storefrontWishlist = "$storefront/wishlist";
  static const String storefrontWishlistSummary =
      "$storefront/wishlist/summary";
  static const String storefrontWishlistItems = "$storefront/wishlist/items";
  static const String storefrontWishlistMerge = "$storefront/wishlist/merge";

  // coupon
  static const String storefrontCoupons = "$storefront/coupons";
  static const String storefrontCouponsValidate =
      "$storefront/coupons/validate";
}
