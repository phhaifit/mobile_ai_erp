import 'package:mobile_ai_erp/domain/entity/checkout/checkout_item.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_order.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/delivery_address.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/payment_method.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/shipping_method.dart';

/// Repository interface for checkout operations
abstract class CheckoutRepository {
  /// Get available shipping methods for a given destination
  Future<List<ShippingMethod>> getShippingMethods({
    required String countryCode,
    double? orderTotal,
    double? totalWeight,
  });

  /// Get available payment methods
  Future<List<PaymentMethod>> getPaymentMethods({
    double? orderTotal,
    String? countryCode,
  });

  /// Validate and retrieve a coupon by code
  Future<Coupon?> validateCoupon(String code, {double? orderTotal});

  /// Validate an address
  Future<DeliveryAddress> validateAddress(DeliveryAddress address);

  /// Parse a raw address string into structured format (AI parsing)
  Future<DeliveryAddress?> parseAddress(String rawAddress);

  /// Create a new checkout order
  Future<CheckoutOrder> createOrder(CheckoutOrder order);

  /// Get an order by ID
  Future<CheckoutOrder?> getOrderById(String orderId);

  /// Update an existing order
  Future<CheckoutOrder> updateOrder(CheckoutOrder order);

  /// Confirm an order for processing
  Future<CheckoutOrder> confirmOrder(String orderId);

  /// Get saved addresses for a customer
  Future<List<DeliveryAddress>> getSavedAddresses(String? customerId);

  /// Save a new address
  Future<DeliveryAddress> saveAddress(DeliveryAddress address);

  /// Delete a saved address
  Future<void> deleteAddress(String addressId);
}
