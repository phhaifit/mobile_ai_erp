import 'package:mobile_ai_erp/domain/entity/checkout/checkout_order.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/delivery_address.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/payment_method.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/shipping_method.dart';

/// Interface for checkout data source
abstract class CheckoutDataSource {
  /// Get available shipping methods
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

  /// Validate and get coupon by code
  Future<Coupon?> validateCoupon(String code, {double? orderTotal});

  /// Validate address (AI smart parsing simulation)
  Future<DeliveryAddress> validateAddress(DeliveryAddress address);

  /// Parse raw address string into structured address
  Future<DeliveryAddress?> parseAddress(String rawAddress);

  /// Create a new checkout order
  Future<CheckoutOrder> createOrder(CheckoutOrder order);

  /// Get order by ID
  Future<CheckoutOrder?> getOrderById(String orderId);

  /// Update order
  Future<CheckoutOrder> updateOrder(CheckoutOrder order);

  /// Confirm order and get order confirmation
  Future<CheckoutOrder> confirmOrder(String orderId);

  /// Get saved addresses for a customer
  Future<List<DeliveryAddress>> getSavedAddresses(String? customerId);

  /// Save a new address
  Future<DeliveryAddress> saveAddress(DeliveryAddress address);

  /// Delete a saved address
  Future<void> deleteAddress(String addressId);
}

/// Mock implementation of CheckoutDataSource
class CheckoutLocalDataSourceImpl implements CheckoutDataSource {
  // In-memory storage for mock data
  final List<ShippingMethod> _shippingMethods = _createMockShippingMethods();
  final List<PaymentMethod> _paymentMethods = _createMockPaymentMethods();
  final List<Coupon> _coupons = _createMockCoupons();
  final List<DeliveryAddress> _savedAddresses = _createMockSavedAddresses();
  final List<CheckoutOrder> _orders = [];

  @override
  Future<List<ShippingMethod>> getShippingMethods({
    required String countryCode,
    double? orderTotal,
    double? totalWeight,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Return all shipping methods (in real app, filter by country, weight, etc.)
    return _shippingMethods.map((method) {
      // Simulate unavailable shipping for some cases
      if (method.id == 'express' && (totalWeight ?? 0) > 10) {
        return method.copyWith(
          isAvailable: false,
          unavailableReason: 'Not available for orders over 10kg',
        );
      }
      return method;
    }).toList();
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods({
    double? orderTotal,
    String? countryCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _paymentMethods.where((method) {
      if (orderTotal != null && !method.isAvailableForAmount(orderTotal)) {
        return false;
      }
      return method.isEnabled;
    }).toList();
  }

  @override
  Future<Coupon?> validateCoupon(String code, {double? orderTotal}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final normalizedCode = code.toUpperCase().trim();
    final coupon = _coupons.where((c) => c.code == normalizedCode).firstOrNull;

    if (coupon == null) return null;

    // Validate the coupon
    final error = coupon.validate(orderTotal ?? 0);
    if (error != null) return null;

    return coupon;
  }

  @override
  Future<DeliveryAddress> validateAddress(DeliveryAddress address) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Simulate address validation (AI parsing simulation)
    // In a real app, this would call an address validation API
    return address.copyWith(
      isVerified: true,
    );
  }

  @override
  Future<DeliveryAddress?> parseAddress(String rawAddress) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate AI address parsing
    // In a real app, this would use an AI service to parse the address
    final parts = rawAddress.split(',').map((p) => p.trim()).toList();

    if (parts.length < 3) return null;

    return DeliveryAddress(
      id: 'parsed-${DateTime.now().millisecondsSinceEpoch}',
      fullName: '',
      phone: '',
      street: parts.isNotEmpty ? parts[0] : '',
      city: parts.length > 1 ? parts[1] : '',
      state: parts.length > 2 ? parts[2] : null,
      postalCode: parts.length > 3 ? parts[3] : null,
      countryCode: 'US',
      isVerified: false,
    );
  }

  @override
  Future<CheckoutOrder> createOrder(CheckoutOrder order) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newOrder = order.copyWith(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      status: CheckoutOrderStatus.draft,
    );

    _orders.add(newOrder);
    return newOrder;
  }

  @override
  Future<CheckoutOrder?> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _orders.where((o) => o.id == orderId).firstOrNull;
  }

  @override
  Future<CheckoutOrder> updateOrder(CheckoutOrder order) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _orders[index] = order.copyWith(updatedAt: DateTime.now());
      return _orders[index];
    }

    // If order doesn't exist, add it
    _orders.add(order.copyWith(updatedAt: DateTime.now()));
    return order;
  }

  @override
  Future<CheckoutOrder> confirmOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('Order not found: $orderId');
    }

    final order = _orders[index];
    if (!order.isReadyForConfirmation) {
      throw Exception('Order is not ready for confirmation');
    }

    _orders[index] = order.copyWith(
      status: CheckoutOrderStatus.confirmed,
      confirmedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _orders[index];
  }

  @override
  Future<List<DeliveryAddress>> getSavedAddresses(String? customerId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (customerId == null) return [];

    return _savedAddresses.where((a) => a.id.contains(customerId)).toList();
  }

  @override
  Future<DeliveryAddress> saveAddress(DeliveryAddress address) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newAddress = address.copyWith(
      id: 'ADDR-${DateTime.now().millisecondsSinceEpoch}',
    );

    _savedAddresses.add(newAddress);
    return newAddress;
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    _savedAddresses.removeWhere((a) => a.id == addressId);
  }

  // ==================== Mock Data Generators ====================

  static List<ShippingMethod> _createMockShippingMethods() {
    return [
      const ShippingMethod(
        id: 'standard',
        name: 'Standard Shipping',
        description: 'Regular delivery with tracking',
        baseCost: 5.99,
        estimatedDays: 5,
        carrier: 'Local Post',
        trackingSupported: true,
        insuranceIncluded: false,
      ),
      const ShippingMethod(
        id: 'express',
        name: 'Express Delivery',
        description: 'Fast delivery with priority handling',
        baseCost: 12.99,
        estimatedDays: 2,
        carrier: 'Express Co.',
        trackingSupported: true,
        insuranceIncluded: true,
      ),
      const ShippingMethod(
        id: 'overnight',
        name: 'Overnight Shipping',
        description: 'Next business day delivery',
        baseCost: 24.99,
        estimatedDays: 1,
        carrier: 'FastShip',
        trackingSupported: true,
        insuranceIncluded: true,
      ),
      const ShippingMethod(
        id: 'pickup',
        name: 'Store Pickup',
        description: 'Pick up at our store location',
        baseCost: 0.0,
        estimatedDays: 1,
        trackingSupported: false,
        insuranceIncluded: false,
      ),
    ];
  }

  static List<PaymentMethod> _createMockPaymentMethods() {
    return [
      const PaymentMethod(
        id: 'cod',
        type: PaymentMethodType.cod,
        name: 'Cash on Delivery',
        isEnabled: true,
        description: 'Pay with cash when your order arrives',
        fee: 2.00,
        processingTime: 'Pay on delivery',
      ),
      const PaymentMethod(
        id: 'bank-transfer',
        type: PaymentMethodType.bankTransfer,
        name: 'Bank Transfer',
        isEnabled: true,
        description: 'Transfer directly to our bank account',
        fee: 0.0,
        instructions:
            'Bank: First National Bank\nAccount: 1234-5678-9012\nName: My Store Inc.',
        processingTime: '1-2 business days',
      ),
      const PaymentMethod(
        id: 'e-wallet',
        type: PaymentMethodType.eWallet,
        name: 'E-Wallet',
        isEnabled: true,
        description: 'Pay with PayPal, Apple Pay, or Google Pay',
        feePercentage: 1.5,
        processingTime: 'Instant',
      ),
      const PaymentMethod(
        id: 'credit-card',
        type: PaymentMethodType.creditCard,
        name: 'Credit/Debit Card',
        isEnabled: true,
        description: 'Visa, Mastercard, American Express',
        feePercentage: 2.5,
        minAmount: 1.0,
        maxAmount: 10000.0,
        processingTime: 'Instant',
        requiresVerification: true,
      ),
      const PaymentMethod(
        id: 'payment-gateway',
        type: PaymentMethodType.paymentGateway,
        name: 'Payment Gateway',
        isEnabled: true,
        description: 'Secure payment via Stripe',
        feePercentage: 2.9,
        processingTime: 'Instant',
        gatewayConfig: {
          'provider': 'stripe',
          'publishableKey': 'pk_test_xxx',
        },
      ),
    ];
  }

  static List<Coupon> _createMockCoupons() {
    return [
      Coupon(
        code: 'SAVE10',
        discountType: CouponDiscountType.percentage,
        discountValue: 10.0,
        isValid: true,
        description: '10% off your order',
        minOrderAmount: 50.0,
        validFrom: DateTime.now().subtract(const Duration(days: 30)),
        validUntil: DateTime.now().add(const Duration(days: 30)),
      ),
      Coupon(
        code: 'FLAT20',
        discountType: CouponDiscountType.fixed,
        discountValue: 20.0,
        isValid: true,
        description: '\$20 off orders over \$100',
        minOrderAmount: 100.0,
        maxDiscountAmount: 20.0,
        validFrom: DateTime.now().subtract(const Duration(days: 10)),
        validUntil: DateTime.now().add(const Duration(days: 60)),
      ),
      Coupon(
        code: 'FREESHIP',
        discountType: CouponDiscountType.freeShipping,
        discountValue: 0.0,
        isValid: true,
        description: 'Free shipping on your order',
        freeShipping: true,
        validFrom: DateTime.now().subtract(const Duration(days: 7)),
        validUntil: DateTime.now().add(const Duration(days: 7)),
      ),
      Coupon(
        code: 'FIRST50',
        discountType: CouponDiscountType.percentage,
        discountValue: 15.0,
        isValid: true,
        description: '15% off for first-time customers',
        minOrderAmount: 30.0,
        isFirstOrderOnly: true,
        validFrom: DateTime.now().subtract(const Duration(days: 90)),
        validUntil: DateTime.now().add(const Duration(days: 90)),
      ),
      Coupon(
        code: 'EXPIRED',
        discountType: CouponDiscountType.percentage,
        discountValue: 50.0,
        isValid: true,
        description: 'This coupon has expired',
        validFrom: DateTime.now().subtract(const Duration(days: 60)),
        validUntil: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<DeliveryAddress> _createMockSavedAddresses() {
    return [
      const DeliveryAddress(
        id: 'ADDR-001',
        fullName: 'John Doe',
        phone: '+1 (555) 123-4567',
        street: '123 Main Street, Apt 4B',
        city: 'New York',
        state: 'NY',
        stateCode: 'NY',
        postalCode: '10001',
        countryCode: 'US',
        country: 'United States',
        label: AddressLabel.home,
        isDefault: true,
        isVerified: true,
      ),
      const DeliveryAddress(
        id: 'ADDR-002',
        fullName: 'John Doe',
        phone: '+1 (555) 987-6543',
        street: '456 Business Ave, Suite 100',
        city: 'New York',
        state: 'NY',
        stateCode: 'NY',
        postalCode: '10002',
        countryCode: 'US',
        country: 'United States',
        label: AddressLabel.work,
        companyName: 'Tech Corp Inc.',
        isDefault: false,
        isVerified: true,
      ),
    ];
  }
}
