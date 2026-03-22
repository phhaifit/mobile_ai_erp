import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/cart/models/cart_ui_model.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/cart_item_card.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/coupon_form_widget.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/empty_cart_state.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/mini_cart_drawer.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/payment_methods_widget.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/price_summary_card.dart';

/// Full shopping cart screen with all cart management features
class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartStore _cartStore;
  String? _selectedPaymentMethod;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _cartStore = GetIt.instance<CartStore>();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    await _cartStore.loadCart();
  }

  void _handleRemoveItem(String itemId) {
    _cartStore.removeItemFromCart(itemId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Item removed from cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // Undo logic can be implemented here
          },
        ),
      ),
    );
  }

  void _handleQuantityChange(String itemId, int newQuantity) {
    if (newQuantity > 0) {
      _cartStore.updateItemQuantity(itemId, newQuantity);
    }
  }

  void _handleApplyCoupon(String couponCode) {
    _cartStore.applyCoupon(couponCode);
  }

  void _handleRemoveCoupon() {
    _cartStore.removeCoupon();
  }

  void _handleContinueShopping() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/products',
      (route) => false,
    );
  }

  void _handleApproveCheckout() {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to terms and conditions'),
        ),
      );
      return;
    }

    // Proceed to checkout
    Navigator.of(context).pushNamed('/checkout', arguments: {
      'paymentMethod': _selectedPaymentMethod,
      'cartData': CartUIModel.fromEntity(_cartStore.cart),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Shopping Cart'),
          elevation: 0,
          centerTitle: true,
          actions: [
            if (_cartStore.itemCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    '${_cartStore.itemCount} item${_cartStore.itemCount != 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_cartStore.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cartStore.errorMessage != null) {
      return _buildErrorState();
    }

    if (_cartStore.isEmpty) {
      return EmptyCartState(
        onContinueShopping: _handleContinueShopping,
        title: 'Your Cart is Empty',
        message: 'Add items to get started with your shopping',
        buttonText: 'Start Shopping',
        icon: Icons.shopping_cart_outlined,
      );
    }

    final cartUIModel = CartUIModel.fromEntity(_cartStore.cart);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cart items section
            _buildCartItemsSection(cartUIModel),
            const SizedBox(height: 24),

            // Coupon section
            CouponFormWidget(
              onApplyCoupon: _handleApplyCoupon,
              onRemoveCoupon: _handleRemoveCoupon,
              appliedCouponCode: _cartStore.appliedCouponCode,
              isLoading: _cartStore.isLoading,
              error: _cartStore.errorMessage,
              success: _cartStore.appliedCouponCode != null
                  ? 'Coupon applied successfully!'
                  : null,
            ),
            const SizedBox(height: 24),

            // Price summary section
            PriceSummaryCard(
              subtotal: cartUIModel.subtotal,
              discountAmount: cartUIModel.discountAmount,
              taxAmount: cartUIModel.taxAmount,
              shippingAmount: cartUIModel.shippingAmount,
              total: cartUIModel.total,
              discountLabel: cartUIModel.appliedCoupon != null
                  ? 'Coupon (${cartUIModel.appliedCoupon!.code})'
                  : 'Discount',
              showDividers: true,
            ),
            const SizedBox(height: 24),

            // Payment methods section
            PaymentMethodsWidget(
              onMethodSelected: (method) {
                setState(() => _selectedPaymentMethod = method);
              },
              selectedMethod: _selectedPaymentMethod,
              showSavedCards: true,
            ),
            const SizedBox(height: 16),

            // Terms and conditions checkbox
            SizedBox(
              width: double.infinity,
              child: CheckboxListTile(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() => _agreeToTerms = value ?? false);
                },
                title: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'I agree to '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(
                          color: Colors.blue[600],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Colors.blue[600],
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24),

            // Checkout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleApproveCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Continue shopping button
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _handleContinueShopping,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Continue Shopping'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemsSection(CartUIModel cartUIModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Items in Cart',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (cartUIModel.itemCount > 0)
              GestureDetector(
                onTap: _selectAllItems,
                child: Text(
                  _allItemsSelected ? 'Deselect All' : 'Select All',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Cart items list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cartUIModel.items.length,
          itemBuilder: (context, index) {
            final item = cartUIModel.items[index];
            return CartItemCard(
              item: item,
              onRemove: () => _handleRemoveItem(item.id),
              onQuantityChanged: (newQuantity) =>
                  _handleQuantityChange(item.id, newQuantity),
              onTap: () {
                // Navigate to product details if needed
              },
              showStockWarning: true,
              isSelected: _cartStore.selectedItemIds.contains(item.id),
              onSelectChanged: (isSelected) {
                _cartStore.toggleItemSelection(item.id);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _cartStore.errorMessage ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeCart,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  bool get _allItemsSelected =>
      _cartStore.selectedItemIds.length == _cartStore.itemCount;

  void _selectAllItems() {
    if (_allItemsSelected) {
      _cartStore.clearSelection();
    } else {
      _cartStore.selectAllItems();
    }
  }
}

/// Cart screen scaffold wrapper with drawer
class CartScreenWithDrawer extends StatefulWidget {
  const CartScreenWithDrawer({Key? key}) : super(key: key);

  @override
  State<CartScreenWithDrawer> createState() => _CartScreenWithDrawerState();
}

class _CartScreenWithDrawerState extends State<CartScreenWithDrawer> {
  late final CartStore _cartStore;

  @override
  void initState() {
    super.initState();
    _cartStore = GetIt.instance<CartStore>();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final cartUIModel = CartUIModel.fromEntity(_cartStore.cart);
        return Scaffold(
          body: const CartScreen(),
          endDrawer: cartUIModel.isEmpty
              ? null
              : MiniCartDrawer(
                  cartData: cartUIModel,
                  onViewFullCart: () => Navigator.pop(context),
                  onCheckout: _handleCheckout,
                  onRemoveItem: _cartStore.removeItemFromCart,
                  onQuantityChanged: _cartStore.updateItemQuantity,
                  isLoading: _cartStore.isLoading,
                  onDrawerToggle: () {
                    if (Scaffold.of(context).isEndDrawerOpen) {
                      Navigator.pop(context);
                    } else {
                      Scaffold.of(context).openEndDrawer();
                    }
                  },
                ),
        );
      },
    );
  }

  void _handleCheckout() {
    Navigator.pop(context);
    Navigator.of(context).pushNamed('/checkout', arguments: {
      'cartData': CartUIModel.fromEntity(_cartStore.cart),
    });
  }
}
