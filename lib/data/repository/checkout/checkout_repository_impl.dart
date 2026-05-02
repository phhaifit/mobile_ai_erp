import 'package:mobile_ai_erp/data/local/datasources/checkout/checkout_datasource.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/addresses_api.dart';
import 'package:mobile_ai_erp/data/network/apis/storefront/checkout_api.dart';
import 'package:mobile_ai_erp/data/network/apis/coupon/coupon_api.dart';
import 'package:mobile_ai_erp/domain/entity/address/address.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_order.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/delivery_address.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/payment_method.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/shipping_method.dart';
import 'package:mobile_ai_erp/domain/repository/checkout/checkout_repository.dart';

/// Implementation of CheckoutRepository that uses real APIs where available
/// and falls back to mock data source for features without backend APIs.
class CheckoutRepositoryImpl extends CheckoutRepository {
  CheckoutRepositoryImpl(
    this._mockDataSource,
    this._checkoutApi,
    this._addressesApi,
    this._couponApi,
  );

  final CheckoutDataSource _mockDataSource;
  final CheckoutApi _checkoutApi;
  final AddressesApi _addressesApi;
  final CouponApi _couponApi;

  // ==================== Real API methods ====================

  @override
  Future<CheckoutOrder> createOrder(CheckoutOrder order) async {
    // Build the address string from the delivery address
    final address = order.deliveryAddress;
    final addressString = address != null
        ? _formatDeliveryAddress(address)
        : '';

    // Determine payment method string for the API
    final paymentMethodStr = _mapPaymentMethodToApiValue(order.paymentMethod);

    // Extract coupon code if applied
    final couponCode = order.coupon?.code;

    // Extract shipping fee
    final shippingFee = order.shippingMethod?.baseCost;

    final response = await _checkoutApi.checkout(
      address: addressString,
      paymentMethod: paymentMethodStr,
      couponCode: couponCode,
      shippingFee: shippingFee,
      customerPhone: order.customerPhone ?? address?.phone,
      customerNote: order.notes,
    );

    // Parse the checkout response into a CheckoutOrder
    return _parseCheckoutResponse(response, order);
  }

  @override
  Future<CheckoutOrder> confirmOrder(String orderId) async {
    // The backend checkout API creates the order in one step,
    // so confirmation is already done. Return a confirmed order.
    // In the future, a dedicated confirm endpoint can be added.
    return CheckoutOrder(
      id: orderId,
      items: const [],
      status: CheckoutOrderStatus.confirmed,
      confirmedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<DeliveryAddress>> getSavedAddresses(String? customerId) async {
    try {
      final addresses = await _addressesApi.getAddresses();
      return addresses.map(_mapAddressToDeliveryAddress).toList();
    } catch (e) {
      // Fallback to mock if API fails (e.g., guest user not authenticated)
      return _mockDataSource.getSavedAddresses(customerId);
    }
  }

  @override
  Future<DeliveryAddress> saveAddress(DeliveryAddress address) async {
    final apiAddress = _mapDeliveryAddressToAddress(address);
    final saved = await _addressesApi.createAddress(apiAddress);
    return _mapAddressToDeliveryAddress(saved);
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await _addressesApi.deleteAddress(addressId);
  }

  @override
  Future<Coupon?> validateCoupon(String code, {double? orderTotal}) async {
    try {
      final response = await _couponApi.validateCoupon(
        couponCode: code,
        subtotal: orderTotal ?? 0,
      );
      return _parseCouponResponse(response);
    } catch (e) {
      // Fallback to mock if API fails
      return _mockDataSource.validateCoupon(code, orderTotal: orderTotal);
    }
  }

  // ==================== Mock-only methods (no backend API yet) ====================

  @override
  Future<List<ShippingMethod>> getShippingMethods({
    required String countryCode,
    double? orderTotal,
    double? totalWeight,
  }) {
    return _mockDataSource.getShippingMethods(
      countryCode: countryCode,
      orderTotal: orderTotal,
      totalWeight: totalWeight,
    );
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods({
    double? orderTotal,
    String? countryCode,
  }) {
    return _mockDataSource.getPaymentMethods(
      orderTotal: orderTotal,
      countryCode: countryCode,
    );
  }

  @override
  Future<DeliveryAddress> validateAddress(DeliveryAddress address) {
    return _mockDataSource.validateAddress(address);
  }

  @override
  Future<DeliveryAddress?> parseAddress(String rawAddress) {
    return _mockDataSource.parseAddress(rawAddress);
  }

  @override
  Future<CheckoutOrder?> getOrderById(String orderId) {
    return _mockDataSource.getOrderById(orderId);
  }

  @override
  Future<CheckoutOrder> updateOrder(CheckoutOrder order) {
    return _mockDataSource.updateOrder(order);
  }

  // ==================== Private helpers ====================

  /// Format a [DeliveryAddress] into a single-line address string for the API.
  String _formatDeliveryAddress(DeliveryAddress addr) {
    final parts = <String>[
      addr.street,
      addr.city,
      if (addr.state != null && addr.state!.isNotEmpty) addr.state!,
      if (addr.postalCode != null && addr.postalCode!.isNotEmpty) addr.postalCode!,
      addr.country ?? addr.countryCode,
    ];
    return parts.join(', ');
  }

  /// Map a [PaymentMethod] to the API payment method string value.
  String _mapPaymentMethodToApiValue(PaymentMethod? method) {
    if (method == null) return 'cod';
    switch (method.type) {
      case PaymentMethodType.cod:
        return 'cod';
      case PaymentMethodType.bankTransfer:
        return 'bank_transfer';
      case PaymentMethodType.eWallet:
        return 'e_wallet';
      case PaymentMethodType.creditCard:
        return 'credit_card';
      case PaymentMethodType.paymentGateway:
        return 'payment_gateway';
    }
  }

  /// Parse the checkout API response into a [CheckoutOrder].
  CheckoutOrder _parseCheckoutResponse(
    Map<String, dynamic> response,
    CheckoutOrder originalOrder,
  ) {
    final orderData = response['order'] as Map<String, dynamic>?;
    // Payment data available in response['payment'] for future use

    // Determine order status from response
    CheckoutOrderStatus status = CheckoutOrderStatus.pending;
    if (orderData != null) {
      final statusStr = orderData['status'] as String? ?? 'pending';
      status = _mapStatusToCheckoutStatus(statusStr);
    }

    return CheckoutOrder(
      id: orderData?['id'] as String? ?? originalOrder.id,
      items: originalOrder.items,
      status: status,
      customerId: originalOrder.customerId,
      customerEmail: originalOrder.customerEmail,
      customerPhone: originalOrder.customerPhone,
      customerName: originalOrder.customerName,
      deliveryAddress: originalOrder.deliveryAddress,
      billingAddress: originalOrder.billingAddress,
      shippingMethod: originalOrder.shippingMethod,
      paymentMethod: originalOrder.paymentMethod,
      coupon: originalOrder.coupon,
      notes: originalOrder.notes,
      createdAt: originalOrder.createdAt,
      confirmedAt: status == CheckoutOrderStatus.confirmed ? DateTime.now() : null,
    );
  }

  /// Map backend order status string to [CheckoutOrderStatus].
  CheckoutOrderStatus _mapStatusToCheckoutStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return CheckoutOrderStatus.pending;
      case 'processing':
        return CheckoutOrderStatus.processing;
      case 'confirmed':
        return CheckoutOrderStatus.confirmed;
      case 'cancelled':
      case 'canceled':
        return CheckoutOrderStatus.cancelled;
      case 'draft':
      default:
        return CheckoutOrderStatus.draft;
    }
  }

  /// Map an [Address] entity (from the addresses API) to a [DeliveryAddress].
  DeliveryAddress _mapAddressToDeliveryAddress(Address addr) {
    return DeliveryAddress(
      id: addr.id,
      fullName: addr.fullName,
      phone: addr.phone,
      street: addr.street,
      city: addr.city,
      countryCode: 'VN',
      label: _mapAddressTypeToLabel(addr.type),
      state: addr.province,
      postalCode: addr.ward,
      isDefault: addr.isDefault,
    );
  }

  /// Map a [DeliveryAddress] to an [Address] entity for the addresses API.
  Address _mapDeliveryAddressToAddress(DeliveryAddress addr) {
    return Address(
      id: addr.id,
      fullName: addr.fullName,
      phone: addr.phone,
      street: addr.street,
      city: addr.city,
      isDefault: addr.isDefault,
      type: _mapLabelToAddressType(addr.label),
      province: addr.state,
      district: null,
      ward: addr.postalCode,
    );
  }

  /// Map address type string to [AddressLabel].
  AddressLabel _mapAddressTypeToLabel(String? type) {
    if (type == null) return AddressLabel.home;
    switch (type.toLowerCase()) {
      case 'work':
      case 'office':
        return AddressLabel.work;
      case 'home':
      default:
        return AddressLabel.home;
    }
  }

  /// Map [AddressLabel] to address type string.
  String _mapLabelToAddressType(AddressLabel label) {
    switch (label) {
      case AddressLabel.work:
        return 'office';
      case AddressLabel.home:
      case AddressLabel.other:
        return 'home';
    }
  }

  /// Parse the coupon validation API response into a [Coupon].
  Coupon? _parseCouponResponse(Map<String, dynamic> response) {
    if (response.isEmpty) return null;

    final valid = response['valid'] as bool? ?? response['isValid'] as bool? ?? false;
    if (!valid) return null;

    final discountTypeStr = response['discountType'] as String? ?? 'fixed';
    final discountType = discountTypeStr == 'percentage'
        ? CouponDiscountType.percentage
        : CouponDiscountType.fixed;

    return Coupon(
      code: response['code'] as String? ?? '',
      discountType: discountType,
      discountValue: (response['discountValue'] as num?)?.toDouble() ?? 0.0,
      isValid: true,
      description: response['description'] as String?,
      minOrderAmount: (response['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      maxDiscountAmount: (response['maxDiscountAmount'] as num?)?.toDouble(),
    );
  }
}
