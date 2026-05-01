import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/data/network/apis/cart/cart_api.dart';
import 'package:mobile_ai_erp/data/network/apis/wishlist/wishlist_api.dart';
import 'package:mobile_ai_erp/data/network/apis/coupon/coupon_api.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/product/product_repository.dart';
import 'package:mobile_ai_erp/data/repository/product/product_repository_impl.dart';
import 'package:mobile_ai_erp/data/repository/coupon/coupon_repository.dart';
import 'package:mobile_ai_erp/data/repository/coupon/coupon_repository_impl.dart';

class CartDataModule {
  CartDataModule._();

  static void setup(GetIt getIt) {
    _setupRepository(getIt);
  }

  static void _setupRepository(GetIt getIt) {
    if (!getIt.isRegistered<CartRepository>()) {
      getIt.registerSingleton<CartRepository>(
        CartRepositoryImpl(
          cartApi: getIt<CartApi>(),
          wishlistApi: getIt<WishlistApi>(),
        ),
      );
    }

    if (!getIt.isRegistered<CouponRepository>()) {
      getIt.registerSingleton<CouponRepository>(
        CouponRepositoryImpl(couponApi: getIt<CouponApi>()),
      );
    }

    if (!getIt.isRegistered<ProductRepository>()) {
      getIt.registerSingleton<ProductRepository>(ProductRepositoryImpl());
    }
  }

  static void reset(GetIt getIt) {
    if (getIt.isRegistered<CartRepository>()) {
      getIt.unregister<CartRepository>();
    }

    if (getIt.isRegistered<CouponRepository>()) {
      getIt.unregister<CouponRepository>();
    }

    if (getIt.isRegistered<ProductRepository>()) {
      getIt.unregister<ProductRepository>();
    }
  }

  static bool isRegistered(GetIt getIt) {
    return getIt.isRegistered<CartRepository>() &&
        getIt.isRegistered<ProductRepository>() &&
        getIt.isRegistered<CouponRepository>();
  }
}
