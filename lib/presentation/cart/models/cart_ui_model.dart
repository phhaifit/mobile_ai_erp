import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_calculation.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist.dart';

class CartUIModel {
  final Cart cart;
  final CartCalculation? calculation;

  const CartUIModel({required this.cart, this.calculation});

  bool get isEmpty => cart.items.isEmpty;
  bool get hasCoupon => calculation?.coupon != null;
  bool get hasLowStockItems => cart.items.any((item) => item.stockWarning);
  bool get hasOutOfStockItems => cart.items.any((item) => !item.isAvailable);
  bool get isEligibleForCheckout => !isEmpty && !hasOutOfStockItems;
}

class WishlistUIModel {
  final Wishlist wishlist;

  const WishlistUIModel({required this.wishlist});

  bool get isEmpty => wishlist.items.isEmpty;
}
