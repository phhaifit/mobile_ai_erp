import 'package:mobile_ai_erp/data/local/datasources/checkout/checkout_datasource.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_item.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_order.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/delivery_address.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/payment_method.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/shipping_method.dart';
import 'package:mobile_ai_erp/domain/repository/checkout/checkout_repository.dart';

/// Implementation of CheckoutRepository
class CheckoutRepositoryImpl extends CheckoutRepository {
  CheckoutRepositoryImpl(this._dataSource);

  final CheckoutDataSource _dataSource;

  @override
  Future<List<ShippingMethod>> getShippingMethods({
    required String countryCode,
    double? orderTotal,
    double? totalWeight,
  }) {
    return _dataSource.getShippingMethods(
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
    return _dataSource.getPaymentMethods(
      orderTotal: orderTotal,
      countryCode: countryCode,
    );
  }

  @override
  Future<Coupon?> validateCoupon(String code, {double? orderTotal}) {
    return _dataSource.validateCoupon(code, orderTotal: orderTotal);
  }

  @override
  Future<DeliveryAddress> validateAddress(DeliveryAddress address) {
    return _dataSource.validateAddress(address);
  }

  @override
  Future<DeliveryAddress?> parseAddress(String rawAddress) {
    return _dataSource.parseAddress(rawAddress);
  }

  @override
  Future<CheckoutOrder> createOrder(CheckoutOrder order) {
    return _dataSource.createOrder(order);
  }

  @override
  Future<CheckoutOrder?> getOrderById(String orderId) {
    return _dataSource.getOrderById(orderId);
  }

  @override
  Future<CheckoutOrder> updateOrder(CheckoutOrder order) {
    return _dataSource.updateOrder(order);
  }

  @override
  Future<CheckoutOrder> confirmOrder(String orderId) {
    return _dataSource.confirmOrder(orderId);
  }

  @override
  Future<List<DeliveryAddress>> getSavedAddresses(String? customerId) {
    return _dataSource.getSavedAddresses(customerId);
  }

  @override
  Future<DeliveryAddress> saveAddress(DeliveryAddress address) {
    return _dataSource.saveAddress(address);
  }

  @override
  Future<void> deleteAddress(String addressId) {
    return _dataSource.deleteAddress(addressId);
  }
}
