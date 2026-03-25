/// Exception class for cart-related errors
class CartException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  CartException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() =>
      'CartException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception for invalid cart items
class InvalidCartItemException extends CartException {
  InvalidCartItemException({required String message})
      : super(
          message: message,
          code: 'INVALID_CART_ITEM',
        );
}

/// Exception for insufficient stock
class InsufficientStockException extends CartException {
  final int requestedQuantity;
  final int availableQuantity;

  InsufficientStockException({
    required this.requestedQuantity,
    required this.availableQuantity,
  }) : super(
          message:
              'Insufficient stock. Requested: $requestedQuantity, Available: $availableQuantity',
          code: 'INSUFFICIENT_STOCK',
        );
}

/// Exception for invalid coupon
class InvalidCouponException extends CartException {
  final String couponCode;

  InvalidCouponException({required this.couponCode})
      : super(
          message: 'Invalid or expired coupon: $couponCode',
          code: 'INVALID_COUPON',
        );
}

/// Exception for coupon minimum cart value not met
class CouponMinimumValueException extends CartException {
  final double minValue;
  final double currentValue;
  final String couponCode;

  CouponMinimumValueException({
    required this.minValue,
    required this.currentValue,
    required this.couponCode,
  }) : super(
          message:
              'Coupon "$couponCode" requires minimum cart value of $minValue. Current: $currentValue',
          code: 'COUPON_MINIMUM_VALUE_NOT_MET',
        );
}

/// Exception for empty cart
class EmptyCartException extends CartException {
  EmptyCartException()
      : super(
          message: 'Cannot proceed with empty cart',
          code: 'EMPTY_CART',
        );
}

/// Exception for item not found in cart
class CartItemNotFoundException extends CartException {
  final String itemId;

  CartItemNotFoundException({required this.itemId})
      : super(
          message: 'Item not found in cart: $itemId',
          code: 'ITEM_NOT_FOUND',
        );
}

/// Exception for duplicate cart item
class DuplicateCartItemException extends CartException {
  final String itemId;

  DuplicateCartItemException({required this.itemId})
      : super(
          message: 'Item already exists in cart: $itemId',
          code: 'DUPLICATE_ITEM',
        );
}
