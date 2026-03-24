import 'package:mobile_ai_erp/domain/entity/checkout/checkout_item.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/delivery_address.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/payment_method.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/shipping_method.dart';

/// Enum representing checkout order status
enum CheckoutOrderStatus {
  draft('Draft', 'Order is being created'),
  pending('Pending', 'Awaiting payment'),
  processing('Processing', 'Order is being processed'),
  confirmed('Confirmed', 'Order confirmed'),
  cancelled('Cancelled', 'Order cancelled');

  const CheckoutOrderStatus(this.displayName, this.description);

  final String displayName;
  final String description;
}

/// Represents a complete checkout order
class CheckoutOrder {
  const CheckoutOrder({
    required this.id,
    required this.items,
    required this.createdAt,
    this.status = CheckoutOrderStatus.draft,
    this.deliveryAddress,
    this.billingAddress,
    this.shippingMethod,
    this.paymentMethod,
    this.coupon,
    this.customerId,
    this.customerEmail,
    this.customerPhone,
    this.customerName,
    this.notes,
    this.updatedAt,
    this.confirmedAt,
  });

  /// Unique order identifier
  final String id;

  /// Customer ID (null for guest checkout)
  final String? customerId;

  /// Customer email
  final String? customerEmail;

  /// Customer phone
  final String? customerPhone;

  /// Customer full name
  final String? customerName;

  /// Items in the order
  final List<CheckoutItem> items;

  /// Delivery address
  final DeliveryAddress? deliveryAddress;

  /// Billing address (if different from delivery)
  final DeliveryAddress? billingAddress;

  /// Selected shipping method
  final ShippingMethod? shippingMethod;

  /// Selected payment method
  final PaymentMethod? paymentMethod;

  /// Applied coupon
  final Coupon? coupon;

  /// Order status
  final CheckoutOrderStatus status;

  /// Order notes
  final String? notes;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Confirmation timestamp
  final DateTime? confirmedAt;

  // ==================== Computed Properties ====================

  /// Total number of items
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal before any discounts
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Total item discount
  double get itemDiscount => items.fold(0.0, (sum, item) => sum + item.discount);

  /// Get coupon discount amount
  double get couponDiscount {
    if (coupon == null) return 0.0;
    return coupon!.calculateDiscount(subtotal, shippingCost: shippingCost);
  }

  /// Get shipping cost
  double get shippingCost {
    if (shippingMethod == null) return 0.0;
    return shippingMethod!.baseCost;
  }

  /// Get payment method fee
  double get paymentFee {
    if (paymentMethod == null) return 0.0;
    return paymentMethod!.calculateFee(totalBeforePaymentFee);
  }

  /// Total before payment fee
  double get totalBeforePaymentFee =>
      subtotal - itemDiscount - couponDiscount + shippingCost;

  /// Grand total
  double get grandTotal => totalBeforePaymentFee + paymentFee;

  /// Total savings (discounts)
  double get totalSavings => itemDiscount + couponDiscount;

  /// Check if order has valid delivery address
  bool get hasDeliveryAddress => deliveryAddress != null;

  /// Check if order has valid shipping method
  bool get hasShippingMethod => shippingMethod != null;

  /// Check if order has valid payment method
  bool get hasPaymentMethod => paymentMethod != null;

  /// Check if order is ready for confirmation
  bool get isReadyForConfirmation =>
      hasDeliveryAddress && hasShippingMethod && hasPaymentMethod && items.isNotEmpty;

  /// Check if this is a guest checkout
  bool get isGuestCheckout => customerId == null;

  /// Get formatted order summary
  String get summaryText {
    return 'Order $id: $totalItemCount items, Total: \$${grandTotal.toStringAsFixed(2)}';
  }

  // ==================== Methods ====================

  CheckoutOrder copyWith({
    String? id,
    List<CheckoutItem>? items,
    DeliveryAddress? deliveryAddress,
    DeliveryAddress? billingAddress,
    ShippingMethod? shippingMethod,
    PaymentMethod? paymentMethod,
    Coupon? coupon,
    CheckoutOrderStatus? status,
    String? customerId,
    String? customerEmail,
    String? customerPhone,
    String? customerName,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? confirmedAt,
  }) {
    return CheckoutOrder(
      id: id ?? this.id,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      coupon: coupon ?? this.coupon,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerName: customerName ?? this.customerName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckoutOrder &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
