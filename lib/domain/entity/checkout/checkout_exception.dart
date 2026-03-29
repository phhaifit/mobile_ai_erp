/// Exception thrown during checkout operations
class CheckoutException implements Exception {
  const CheckoutException({
    required this.message,
    this.code,
    this.field,
  });

  /// Human-readable error message
  final String message;

  /// Error code for programmatic handling
  final String? code;

  /// Field that caused the error (for form validation)
  final String? field;

  @override
  String toString() => 'CheckoutException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when address validation fails
class AddressValidationException extends CheckoutException {
  const AddressValidationException({
    required super.message,
    super.code = 'ADDRESS_INVALID',
    super.field,
  });
}

/// Exception thrown when shipping method is unavailable
class ShippingUnavailableException extends CheckoutException {
  const ShippingUnavailableException({
    required super.message,
    super.code = 'SHIPPING_UNAVAILABLE',
  });
}

/// Exception thrown when payment fails
class PaymentFailedException extends CheckoutException {
  const PaymentFailedException({
    required super.message,
    super.code = 'PAYMENT_FAILED',
  });
}

/// Exception thrown when coupon is invalid
class CouponException extends CheckoutException {
  const CouponException({
    required super.message,
    super.code = 'COUPON_INVALID',
  });
}

/// Exception thrown when checkout session expires
class CheckoutSessionExpiredException extends CheckoutException {
  const CheckoutSessionExpiredException({
    super.message = 'Checkout session has expired. Please try again.',
    super.code = 'SESSION_EXPIRED',
  });
}
