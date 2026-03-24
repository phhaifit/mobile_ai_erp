import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_item.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/delivery_address.dart';
import 'package:mobile_ai_erp/presentation/checkout/store/checkout_store.dart';
import 'package:mobile_ai_erp/presentation/checkout/widgets/address_form_widget.dart';
import 'package:mobile_ai_erp/presentation/checkout/widgets/address_selection_widget.dart';
import 'package:mobile_ai_erp/presentation/checkout/widgets/checkout_section_card.dart';
import 'package:mobile_ai_erp/presentation/checkout/widgets/checkout_stepper_widget.dart';
import 'package:mobile_ai_erp/presentation/checkout/widgets/coupon_input_widget.dart';
import 'package:mobile_ai_erp/presentation/checkout/widgets/order_summary_widget.dart';
import 'package:mobile_ai_erp/presentation/checkout/widgets/payment_method_widget.dart';
import 'package:mobile_ai_erp/presentation/checkout/widgets/shipping_method_widget.dart';

/// Main checkout screen with multi-step checkout flow
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.items,
    this.customerId,
  });

  final List<CheckoutItem> items;
  final String? customerId;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CheckoutStore _store = getIt<CheckoutStore>();
  final PageController _pageController = PageController();

  final List<CheckoutStepData> _steps = const [
    CheckoutStepData(label: 'Address', icon: Icons.location_on_outlined),
    CheckoutStepData(label: 'Shipping', icon: Icons.local_shipping_outlined),
    CheckoutStepData(label: 'Payment', icon: Icons.payment_outlined),
    CheckoutStepData(label: 'Review', icon: Icons.receipt_long_outlined),
  ];

  bool _showAddressForm = false;

  @override
  void initState() {
    super.initState();
    _store.initializeCheckout(widget.items, customerId: widget.customerId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step <= _currentStepIndex) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  int get _currentStepIndex {
    switch (_store.currentStep) {
      case CheckoutStep.address:
        return 0;
      case CheckoutStep.shipping:
        return 1;
      case CheckoutStep.payment:
        return 2;
      case CheckoutStep.review:
        return 3;
      case CheckoutStep.confirmation:
        return 4;
      case CheckoutStep.cart:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Observer(
        builder: (context) {
          if (_store.currentStep == CheckoutStep.confirmation) {
            return _buildConfirmationPage(context);
          }

          return Column(
            children: [
              // Stepper
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CheckoutStepperWidget(
                  currentStep: _currentStepIndex,
                  steps: _steps,
                  onStepTapped: _goToStep,
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildAddressStep(context),
                    _buildShippingStep(context),
                    _buildPaymentStep(context),
                    _buildReviewStep(context),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==================== Address Step ====================
  Widget _buildAddressStep(BuildContext context) {
    return Observer(
      builder: (context) {
        if (_store.isLoadingAddresses) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_showAddressForm) {
          return _buildAddressForm(context);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckoutSectionCard(
                title: 'Delivery Address',
                subtitle: _store.currentOrder?.isGuestCheckout ?? true
                    ? 'Enter your delivery address'
                    : 'Select from saved addresses or add new one',
                child: AddressSelectionWidget(
                  addresses: _store.savedAddresses,
                  selectedAddress: _store.selectedDeliveryAddress,
                  onAddressSelected: (address) {
                    _store.selectDeliveryAddress(address);
                  },
                  onAddNewAddress: () {
                    setState(() => _showAddressForm = true);
                  },
                  onEditAddress: _store.currentOrder?.isGuestCheckout ?? true
                      ? null
                      : (address) {
                          setState(() => _showAddressForm = true);
                        },
                ),
              ),
              const SizedBox(height: 24),
              _buildNavigationButtons(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showAddressForm = false),
              ),
              Text(
                'New Address',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AddressFormWidget(
            onParseAddress: (rawAddress) => _store.parseAddress(rawAddress),
            isParsing: false,
            onSave: (address) {
              _store.saveNewAddress(address);
              setState(() => _showAddressForm = false);
            },
          ),
        ],
      ),
    );
  }

  // ==================== Shipping Step ====================
  Widget _buildShippingStep(BuildContext context) {
    return Observer(
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckoutSectionCard(
                title: 'Shipping Method',
                subtitle: _store.selectedDeliveryAddress?.formattedAddress ?? '',
                child: ShippingMethodWidget(
                  shippingMethods: _store.shippingMethods,
                  selectedMethod: _store.selectedShippingMethod,
                  onMethodSelected: (method) {
                    _store.selectShippingMethod(method);
                  },
                  isLoading: _store.isLoadingShippingMethods,
                ),
              ),
              const SizedBox(height: 24),
              _buildNavigationButtons(context),
            ],
          ),
        );
      },
    );
  }

  // ==================== Payment Step ====================
  Widget _buildPaymentStep(BuildContext context) {
    return Observer(
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckoutSectionCard(
                title: 'Payment Method',
                child: PaymentMethodWidget(
                  paymentMethods: _store.paymentMethods,
                  selectedMethod: _store.selectedPaymentMethod,
                  onMethodSelected: (method) {
                    _store.selectPaymentMethod(method);
                  },
                  isLoading: _store.isLoadingPaymentMethods,
                ),
              ),
              const SizedBox(height: 24),
              _buildNavigationButtons(context),
            ],
          ),
        );
      },
    );
  }

  // ==================== Review Step ====================
  Widget _buildReviewStep(BuildContext context) {
    return Observer(
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Address Summary
              if (_store.selectedDeliveryAddress != null)
                CheckoutSectionCard(
                  title: 'Delivery Address',
                  trailing: TextButton(
                    onPressed: () {
                      _goToStep(0);
                    },
                    child: const Text('Edit'),
                  ),
                  child: _buildAddressSummary(context),
                ),
              const SizedBox(height: 16),

              // Shipping Method Summary
              if (_store.selectedShippingMethod != null)
                CheckoutSectionCard(
                  title: 'Shipping Method',
                  trailing: TextButton(
                    onPressed: () {
                      _goToStep(1);
                    },
                    child: const Text('Edit'),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(_store.selectedShippingMethod!.name),
                      const Spacer(),
                      Text(_store.selectedShippingMethod!.formattedCost),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Payment Method Summary
              if (_store.selectedPaymentMethod != null)
                CheckoutSectionCard(
                  title: 'Payment Method',
                  trailing: TextButton(
                    onPressed: () {
                      _goToStep(2);
                    },
                    child: const Text('Edit'),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payment_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(_store.selectedPaymentMethod!.name),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Coupon Section
              CheckoutSectionCard(
                title: 'Coupon',
                child: CouponInputWidget(
                  onApplyCoupon: (code) async {
                    await _store.applyCoupon(code);
                    return _store.appliedCoupon != null;
                  },
                  onRemoveCoupon: _store.removeCoupon,
                  appliedCouponCode: _store.appliedCoupon?.code,
                  isValidating: _store.isValidatingCoupon,
                  errorMessage: _store.couponError,
                ),
              ),
              const SizedBox(height: 16),

              // Order Summary
              CheckoutSectionCard(
                title: 'Order Summary',
                child: OrderSummaryWidget(
                  items: _store.currentOrder?.items ?? [],
                  subtotal: _store.subtotal,
                  shippingCost: _store.shippingCost,
                  paymentFee: _store.paymentFee,
                  discount: _store.couponDiscount,
                  grandTotal: _store.grandTotal,
                  couponCode: _store.appliedCoupon?.code,
                  onRemoveCoupon: _store.removeCoupon,
                ),
              ),
              const SizedBox(height: 24),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _store.isReadyForConfirmation &&
                          !_store.isProcessingOrder
                      ? _placeOrder
                      : null,
                  child: _store.isProcessingOrder
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Place Order - ${_store.formattedGrandTotal}'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressSummary(BuildContext context) {
    final address = _store.selectedDeliveryAddress;
    if (address == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          address.fullName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          address.phone ?? '',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          address.formattedAddress,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  // ==================== Confirmation Page ====================
  Widget _buildConfirmationPage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Order Placed!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for your order. You will receive a confirmation email shortly.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: ${_store.currentOrder?.id ?? ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Navigation ====================
  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      children: [
        if (_currentStepIndex > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Back'),
            ),
          ),
        if (_currentStepIndex > 0) const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: _canProceed() ? _nextStep : null,
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }

  bool _canProceed() {
    switch (_store.currentStep) {
      case CheckoutStep.address:
        return _store.selectedDeliveryAddress != null;
      case CheckoutStep.shipping:
        return _store.selectedShippingMethod != null;
      case CheckoutStep.payment:
        return _store.selectedPaymentMethod != null;
      case CheckoutStep.review:
        return _store.isReadyForConfirmation;
      default:
        return false;
    }
  }

  void _nextStep() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _placeOrder() async {
    final success = await _store.confirmOrder();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
