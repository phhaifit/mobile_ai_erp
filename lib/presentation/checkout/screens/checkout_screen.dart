import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/checkout_item.dart';
import 'package:mobile_ai_erp/domain/entity/checkout/delivery_address.dart';
import 'package:mobile_ai_erp/presentation/checkout/store/checkout_store.dart';
import 'package:mobile_ai_erp/presentation/checkout/widgets/order_summary_widget.dart';
import 'package:mobile_ai_erp/presentation/checkout/widgets/coupon_input_widget.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/payment_methods_widget.dart';

/// Main checkout screen with single-page layout
/// All sections (address, shipping, payment, summary) are visible on one page
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

  @override
  void initState() {
    super.initState();
    _store.initializeCheckout(widget.items, customerId: widget.customerId);
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

          if (_store.isLoadingAddresses ||
              _store.isLoadingShippingMethods ||
              _store.isLoadingPaymentMethods) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address Section (includes email)
                      _buildAddressSection(context),
                      const SizedBox(height: 16),

                      // Shipping Method Section
                      _buildShippingSection(context),
                      const SizedBox(height: 16),

                      // Payment Method Section
                      _buildPaymentSection(context),
                      const SizedBox(height: 16),

                      // Coupon Section
                      _buildCouponSection(context),
                      const SizedBox(height: 16),

                      // Order Summary Section
                      _buildOrderSummarySection(context),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
              // Bottom Place Order Button
              _buildBottomBar(context),
            ],
          );
        },
      ),
    );
  }

  // ==================== Address Section ====================
  Widget _buildAddressSection(BuildContext context) {
    return Observer(
      builder: (context) {
        return _buildSectionCard(
          context: context,
          title: 'Delivery Address',
          icon: Icons.location_on_outlined,
          child: _store.selectedDeliveryAddress != null
              ? _buildSelectedAddress(context)
              : _buildAddAddressButton(context),
        );
      },
    );
  }

  Widget _buildSelectedAddress(BuildContext context) {
    final address = _store.selectedDeliveryAddress!;
    return InkWell(
      onTap: () => _showAddressSelectionSheet(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        address.phone,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Email row (if available)
                  if (address.email != null && address.email!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          address.email!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    address.formattedAddress,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAddressButton(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToAddAddress(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_location_outlined, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              'Add Delivery Address',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Observer(
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _navigateToAddAddress(context);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add New'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _store.savedAddresses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'No saved addresses',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _store.savedAddresses.length,
                            itemBuilder: (context, index) {
                              final address = _store.savedAddresses[index];
                              final isSelected = _store.selectedDeliveryAddress?.id == address.id;
                              return _buildAddressOption(address, isSelected);
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAddressOption(DeliveryAddress address, bool isSelected) {
    return InkWell(
      onTap: () {
        _store.selectDeliveryAddress(address);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) {
                _store.selectDeliveryAddress(address);
                Navigator.pop(context);
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        address.phone,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.formattedAddress,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddAddress(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAddressScreen(),
        fullscreenDialog: true,
      ),
    );

    if (result != null && result is DeliveryAddress) {
      _store.saveNewAddress(result);
    }
  }

  // ==================== Shipping Section ====================
  Widget _buildShippingSection(BuildContext context) {
    return Observer(
      builder: (context) {
        return _buildSectionCard(
          context: context,
          title: 'Shipping Method',
          icon: Icons.local_shipping_outlined,
          child: _store.shippingMethods.isEmpty
              ? const Text('No shipping methods available')
              : Column(
                  children: _store.shippingMethods.map((method) {
                    final isSelected = _store.selectedShippingMethod?.id == method.id;
                    return _buildShippingOption(method, isSelected);
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _buildShippingOption(dynamic method, bool isSelected) {
    return InkWell(
      onTap: () => _store.selectShippingMethod(method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              _getShippingIcon(method.name),
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.estimatedDeliveryText,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              method.formattedCost,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getShippingIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('express') || lowerName.contains('fast')) {
      return Icons.bolt;
    } else if (lowerName.contains('standard') || lowerName.contains('regular')) {
      return Icons.local_shipping;
    } else if (lowerName.contains('economy') || lowerName.contains('saver')) {
      return Icons.savings_outlined;
    }
    return Icons.local_shipping_outlined;
  }

  // ==================== Payment Section ====================
  Widget _buildPaymentSection(BuildContext context) {
    return Observer(
      builder: (context) {
        return _buildSectionCard(
          context: context,
          title: 'Payment Method',
          icon: Icons.payment_outlined,
          child: PaymentMethodsWidget(
            onMethodSelected: (method, savedCardId) {
              _store.setSelectedPaymentMethod(method, savedCardId: savedCardId);
            },
            selectedMethod: _store.selectedPaymentMethodValue,
            showSavedCards: true,
          ),
        );
      },
    );
  }

  // ==================== Coupon Section ====================
  Widget _buildCouponSection(BuildContext context) {
    return Observer(
      builder: (context) {
        return _buildSectionCard(
          context: context,
          title: 'Voucher / Coupon',
          icon: Icons.confirmation_number_outlined,
          child: CouponInputWidget(
            onApplyCoupon: (code) async {
              await _store.applyCoupon(code);
              return _store.appliedCoupon != null && _store.couponError == null;
            },
            onRemoveCoupon: _store.removeCoupon,
            appliedCouponCode: _store.appliedCoupon?.code,
            isValidating: _store.isValidatingCoupon,
            errorMessage: _store.couponError,
          ),
        );
      },
    );
  }

  // ==================== Order Summary Section ====================
  Widget _buildOrderSummarySection(BuildContext context) {
    return Observer(
      builder: (context) {
        return _buildSectionCard(
          context: context,
          title: 'Order Summary',
          icon: Icons.receipt_long_outlined,
          child: OrderSummaryWidget(
            items: widget.items,
            subtotal: _store.subtotal,
            shippingCost: _store.shippingCost,
            paymentFee: _store.paymentFee,
            discount: _store.couponDiscount,
            grandTotal: _store.grandTotal,
            couponCode: _store.appliedCoupon?.code,
            onRemoveCoupon: _store.appliedCoupon != null ? _store.removeCoupon : null,
          ),
        );
      },
    );
  }

  // ==================== Bottom Bar ====================
  Widget _buildBottomBar(BuildContext context) {
    return Observer(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        _store.formattedGrandTotal,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _canPlaceOrder() ? () => _placeOrder(context) : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                  child: _store.isProcessingOrder
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Place Order'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _canPlaceOrder() {
    return _store.isReadyForConfirmation && !_store.isProcessingOrder;
  }

  Future<void> _placeOrder(BuildContext context) async {
    final success = await _store.confirmOrder();

    if (success && mounted) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Order Placed!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ID: ${_store.currentOrder?.id ?? "N/A"}'),
              const SizedBox(height: 8),
              Text('Total: ${_store.formattedGrandTotal}'),
              const SizedBox(height: 16),
              const Text(
                'Thank you for your order! You will receive a confirmation email shortly.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } else if (_store.errorStore.errorMessage.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_store.errorStore.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== Confirmation Page ====================
  Widget _buildConfirmationPage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Order ID: ${_store.currentOrder?.id ?? "N/A"}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Helper Widget ====================
  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Separate screen for adding a new address
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _smartAddressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Ho Chi Minh City');
  final _postalCodeController = TextEditingController(text: '700000');

  bool _isParsingAddress = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _smartAddressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Address'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Smart Address Input
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 18, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Smart Address Input',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paste a full address and we\'ll parse it automatically',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _smartAddressController,
                            decoration: const InputDecoration(
                              hintText: 'e.g., "John Doe, 0901234567, 123 Main St, District 1, HCMC"',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
                            ),
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _parseSmartAddress,
                          icon: _isParsingAddress
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.auto_fix_high),
                          tooltip: 'Parse Address',
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Manual Input
              const Text(
                'Or enter manually',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              // Recipient Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter full name' : null,
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 16),

              // Email Address
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'For order confirmation',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return null; // Optional field
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Street Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address *',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                maxLines: 2,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter address' : null,
              ),
              const SizedBox(height: 16),

              // City
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter city' : null,
              ),
              const SizedBox(height: 16),

              // Postal Code
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Save Address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _parseSmartAddress() async {
    final input = _smartAddressController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an address to parse')),
      );
      return;
    }

    setState(() => _isParsingAddress = true);

    // Simulate AI parsing delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simple parsing logic (in production, use proper AI/NLP)
    final parts = input.split(',').map((p) => p.trim()).toList();

    if (parts.length >= 2) {
      _nameController.text = parts[0];
      // Try to find phone number
      final phoneRegex = RegExp(r'[\d\-\s]{9,}');
      final phoneMatch = phoneRegex.firstMatch(input);
      if (phoneMatch != null) {
        _phoneController.text = phoneMatch.group(0) ?? '';
      } else if (parts.length > 1) {
        _phoneController.text = parts[1];
      }
      // Rest is address
      if (parts.length > 2) {
        _addressController.text = parts.sublist(2).join(', ');
      }
    } else {
      _addressController.text = input;
    }

    setState(() => _isParsingAddress = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address parsed! Please verify and save.')),
      );
    }
  }

  void _saveAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      final address = DeliveryAddress(
        id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
        fullName: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        street: _addressController.text,
        city: _cityController.text,
        countryCode: 'VN',
        postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
        country: 'Vietnam',
        isDefault: false,
      );

      Navigator.of(context).pop(address);
    }
  }
}
