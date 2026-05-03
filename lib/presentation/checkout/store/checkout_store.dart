import 'package:mobile_ai_erp/core/stores/error/error_store.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_item.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_order.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/delivery_address.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/payment_method.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/shipping_method.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/checkout_usecases.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/get_payment_methods_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/get_shipping_methods_usecase.dart';
import 'package:mobile_ai_erp/domain/usecase/checkout/validate_coupon_usecase.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobx/mobx.dart';

part 'checkout_store.g.dart';

// ignore: library_private_types_in_public_api
class CheckoutStore = _CheckoutStore with _$CheckoutStore;

/// Enum representing checkout steps
enum CheckoutStep {
  cart('Cart'),
  address('Delivery Address'),
  shipping('Shipping Method'),
  payment('Payment Method'),
  review('Review Order'),
  confirmation('Order Confirmed');

  const CheckoutStep(this.displayName);

  final String displayName;
}

abstract class _CheckoutStore with Store {
  _CheckoutStore(
    this._getShippingMethodsUseCase,
    this._getPaymentMethodsUseCase,
    this._validateCouponUseCase,
    this._parseAddressUseCase,
    this._createOrderUseCase,
    this._confirmOrderUseCase,
    this._getSavedAddressesUseCase,
    this._saveAddressUseCase,
    this._deleteAddressUseCase,
    this.errorStore,
    this._cartStore,
  );

  // Use cases
  final GetShippingMethodsUseCase _getShippingMethodsUseCase;
  final GetPaymentMethodsUseCase _getPaymentMethodsUseCase;
  final ValidateCouponUseCase _validateCouponUseCase;
  final ParseAddressUseCase _parseAddressUseCase;
  final CreateCheckoutOrderUseCase _createOrderUseCase;
  final ConfirmOrderUseCase _confirmOrderUseCase;
  final GetSavedAddressesUseCase _getSavedAddressesUseCase;
  final SaveAddressUseCase _saveAddressUseCase;
  final DeleteAddressUseCase _deleteAddressUseCase;
  final ErrorStore errorStore;
  final CartStore? _cartStore;

  // ==================== Observables ====================

  @observable
  CheckoutOrder? currentOrder;

  @observable
  ObservableList<ShippingMethod> shippingMethods = ObservableList();

  @observable
  ObservableList<PaymentMethod> paymentMethods = ObservableList();

  @observable
  ObservableList<DeliveryAddress> savedAddresses = ObservableList();

  @observable
  CheckoutStep currentStep = CheckoutStep.address;

  @observable
  ShippingMethod? selectedShippingMethod;

  @observable
  PaymentMethod? selectedPaymentMethod;

  @observable
  DeliveryAddress? selectedDeliveryAddress;

  @observable
  DeliveryAddress? billingAddress;

  @observable
  Coupon? appliedCoupon;

  @observable
  bool isLoadingShippingMethods = false;

  @observable
  bool isLoadingPaymentMethods = false;

  @observable
  bool isLoadingAddresses = false;

  @observable
  bool isValidatingCoupon = false;

  @observable
  bool isProcessingOrder = false;

  @observable
  String? couponCode;

  @observable
  String? couponError;

  @observable
  String? orderNotes;

  @observable
  String? customerEmail;

  @observable
  String? selectedPaymentMethodValue;

  @observable
  String? selectedSavedCardId;

  // ==================== Computed ====================

  @computed
  bool get hasItems => currentOrder?.items.isNotEmpty ?? false;

  @computed
  int get totalItemCount => currentOrder?.totalItemCount ?? 0;

  @computed
  double get subtotal => currentOrder?.subtotal ?? 0;

  @computed
  double get shippingCost => selectedShippingMethod?.baseCost ?? 0;

  @computed
  double get couponDiscount {
    if (appliedCoupon == null) return 0;
    return appliedCoupon!.calculateDiscount(subtotal, shippingCost: shippingCost);
  }

  @computed
  double get paymentFee {
    if (selectedPaymentMethod == null) return 0;
    return selectedPaymentMethod!.calculateFee(subtotal - couponDiscount + shippingCost);
  }

  @computed
  double get grandTotal {
    return subtotal - couponDiscount + shippingCost + paymentFee;
  }

  @computed
  bool get isReadyForConfirmation {
    return hasItems &&
        selectedDeliveryAddress != null &&
        selectedShippingMethod != null &&
        selectedPaymentMethod != null;
  }

  @computed
  String get formattedGrandTotal => '\$${grandTotal.toStringAsFixed(2)}';

  // ==================== Actions ====================

  @action
  void initializeCheckout(List<CheckoutItem> items, {String? customerId, String? initialCouponCode}) {
    _resetState();
    
    currentOrder = CheckoutOrder(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      customerId: customerId,
      createdAt: DateTime.now(),
    );
    currentStep = CheckoutStep.address;
    
    if (initialCouponCode != null && initialCouponCode.isNotEmpty) {
      couponCode = initialCouponCode;
      _loadInitialData().then((_) {
        applyCoupon(initialCouponCode);
      });
    } else {
      _loadInitialData();
    }
  }

  @action
  void _resetState() {
    currentOrder = null;
    currentStep = CheckoutStep.address;
    selectedShippingMethod = null;
    selectedPaymentMethod = null;
    selectedPaymentMethodValue = null;
    selectedSavedCardId = null;
    selectedDeliveryAddress = null;
    billingAddress = null;
    appliedCoupon = null;
    couponCode = null;
    couponError = null;
    shippingMethods.clear();
    paymentMethods.clear();
    savedAddresses.clear();
    isLoadingShippingMethods = false;
    isLoadingPaymentMethods = false;
    isLoadingAddresses = false;
    isProcessingOrder = false;
  }

  @action
  Future<void> _loadInitialData() async {
    await Future.wait([
      loadShippingMethods(),
      loadPaymentMethods(),
      loadSavedAddresses(),
    ]);
  }

  @action
  Future<void> loadShippingMethods() async {
    isLoadingShippingMethods = true;
    try {
      final methods = await _getShippingMethodsUseCase.call(
        params: GetShippingMethodsParams(
          countryCode: selectedDeliveryAddress?.countryCode ?? 'US',
          orderTotal: subtotal,
        ),
      );
      shippingMethods = ObservableList.of(methods);
    } catch (e) {
      errorStore.errorMessage = 'Failed to load shipping methods: $e';
    } finally {
      isLoadingShippingMethods = false;
    }
  }

  @action
  Future<void> loadPaymentMethods() async {
    isLoadingPaymentMethods = true;
    try {
      final methods = await _getPaymentMethodsUseCase.call(
        params: GetPaymentMethodsParams(
          orderTotal: grandTotal,
        ),
      );
      paymentMethods = ObservableList.of(methods);
    } catch (e) {
      errorStore.errorMessage = 'Failed to load payment methods: $e';
    } finally {
      isLoadingPaymentMethods = false;
    }
  }

  @action
  Future<void> loadSavedAddresses() async {
    isLoadingAddresses = true;
    try {
      final addresses = await _getSavedAddressesUseCase.call(
        params: currentOrder?.customerId,
      );
      savedAddresses = ObservableList.of(addresses);
      // Auto-select default address
      if (addresses.isNotEmpty) {
        final defaultAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
        selectDeliveryAddress(defaultAddress);
      }
    } catch (e) {
      errorStore.errorMessage = 'Failed to load addresses: $e';
    } finally {
      isLoadingAddresses = false;
    }
  }

  @action
  void selectDeliveryAddress(DeliveryAddress address) {
    selectedDeliveryAddress = address;
    // Reload shipping methods for new address
    loadShippingMethods();
  }

  @action
  void selectShippingMethod(ShippingMethod method) {
    selectedShippingMethod = method;
  }

  @action
  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod = method;
  }

  @action
  void setSelectedPaymentMethod(String methodValue, {String? savedCardId}) {
    selectedPaymentMethodValue = methodValue;
    selectedSavedCardId = savedCardId;
    
    // Find and set the corresponding PaymentMethod entity
    // Map UI values (snake_case) to datasource IDs (hyphenated)
    final normalizedValue = _normalizePaymentMethodValue(methodValue);
    
    try {
      final method = paymentMethods.firstWhere(
        (m) => m.id == normalizedValue,
        orElse: () => paymentMethods.first,
      );
      selectedPaymentMethod = method;
    } catch (_) {
      // If no matching method found, keep the value for later use
    }
  }
  
  /// Normalize payment method value from UI (snake_case) to datasource ID format (hyphenated)
  String _normalizePaymentMethodValue(String value) {
    // Map UI values to datasource payment method IDs
    final mappings = {
      'credit_card': 'credit-card',
      'debit_card': 'credit-card', // Debit cards use same processor as credit
      'digital_wallet': 'e-wallet',
      'bank_transfer': 'bank-transfer',
      'e_wallet': 'e-wallet',
      'cod': 'cod', // Cash on Delivery - already matches
    };
    
    return mappings[value.toLowerCase()] ?? value.toLowerCase();
  }

  @action
  Future<void> applyCoupon(String code) async {
    isValidatingCoupon = true;
    couponError = null;
    couponCode = code;

    try {
      final coupon = await _validateCouponUseCase.call(
        params: ValidateCouponParams(
          code: code,
          orderTotal: subtotal,
        ),
      );

      if (coupon != null) {
        appliedCoupon = coupon;
        couponError = null;
      } else {
        couponError = 'Invalid coupon code';
        appliedCoupon = null;
      }
    } catch (e) {
      couponError = e.toString();
      appliedCoupon = null;
    } finally {
      isValidatingCoupon = false;
    }
  }

  @action
  void removeCoupon() {
    appliedCoupon = null;
    couponCode = null;
    couponError = null;
  }

  @action
  void setCustomerEmail(String email) {
    customerEmail = email;
  }

  @action
  Future<DeliveryAddress?> parseAddress(String rawAddress) async {
    try {
      return await _parseAddressUseCase.call(params: rawAddress);
    } catch (e) {
      errorStore.errorMessage = 'Failed to parse address: $e';
      return null;
    }
  }

  @action
  Future<void> saveNewAddress(DeliveryAddress address) async {
    try {
      final saved = await _saveAddressUseCase.call(params: address);
      savedAddresses.add(saved);
      selectDeliveryAddress(saved);
    } catch (e) {
      errorStore.errorMessage = 'Failed to save address: $e';
    }
  }

  @action
  Future<void> deleteSavedAddress(String addressId) async {
    try {
      await _deleteAddressUseCase.call(params: addressId);
      savedAddresses.removeWhere((a) => a.id == addressId);
      if (selectedDeliveryAddress?.id == addressId) {
        selectedDeliveryAddress = null;
      }
    } catch (e) {
      errorStore.errorMessage = 'Failed to delete address: $e';
    }
  }

  @action
  void goToStep(CheckoutStep step) {
    currentStep = step;
  }

  @action
  void nextStep() {
    final steps = CheckoutStep.values;
    final currentIndex = steps.indexOf(currentStep);
    if (currentIndex < steps.length - 1) {
      currentStep = steps[currentIndex + 1];
    }
  }

  @action
  void previousStep() {
    final steps = CheckoutStep.values;
    final currentIndex = steps.indexOf(currentStep);
    if (currentIndex > 0) {
      currentStep = steps[currentIndex - 1];
    }
  }

  @action
  void setOrderNotes(String? notes) {
    orderNotes = notes;
  }

  @action
  Future<bool> confirmOrder() async {
    if (!isReadyForConfirmation) {
      errorStore.errorMessage = 'Please complete all required fields';
      return false;
    }

    isProcessingOrder = true;
    try {
      // Create the order with all selected options
      // Use contact info from selected delivery address if available
      final orderToCreate = CheckoutOrder(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        items: currentOrder!.items,
        customerId: currentOrder!.customerId,
        customerEmail: selectedDeliveryAddress?.email ?? currentOrder!.customerEmail,
        customerPhone: selectedDeliveryAddress?.phone ?? currentOrder!.customerPhone,
        customerName: selectedDeliveryAddress?.fullName ?? currentOrder!.customerName,
        deliveryAddress: selectedDeliveryAddress,
        billingAddress: billingAddress ?? selectedDeliveryAddress,
        shippingMethod: selectedShippingMethod,
        paymentMethod: selectedPaymentMethod,
        coupon: appliedCoupon,
        notes: orderNotes,
        createdAt: DateTime.now(),
      );

      final createdOrder = await _createOrderUseCase.call(params: orderToCreate);

      // Save item IDs from the original order before confirmation
      // (confirmOrder returns a stub with empty items)
      final purchasedItemIds = orderToCreate.items.map((item) => item.id).toList();

      // Confirm the order
      final confirmedOrder = await _confirmOrderUseCase.call(
        params: createdOrder.id,
      );

      currentOrder = confirmedOrder;
      currentStep = CheckoutStep.confirmation;
      
      // Clear purchased items from cart after successful order
      if (_cartStore != null && purchasedItemIds.isNotEmpty) {
        await _cartStore.removeMultipleItemsFromCart(purchasedItemIds);
      }
      
      return true;
    } catch (e) {
      errorStore.errorMessage = 'Failed to place order: $e';
      return false;
    } finally {
      isProcessingOrder = false;
    }
  }

  @action
  void resetCheckout() {
    currentOrder = null;
    selectedShippingMethod = null;
    selectedPaymentMethod = null;
    selectedDeliveryAddress = null;
    billingAddress = null;
    appliedCoupon = null;
    couponCode = null;
    couponError = null;
    orderNotes = null;
    currentStep = CheckoutStep.address;
  }
}
