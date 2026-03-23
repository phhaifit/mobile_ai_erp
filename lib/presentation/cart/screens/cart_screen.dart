import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/presentation/cart/models/cart_ui_model.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/cart_item_card.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/coupon_form_widget.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/empty_cart_state.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/mini_cart_drawer.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/payment_methods_widget.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/price_summary_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartStore _cartStore;

  String? _selectedPaymentMethod;
  bool _agreeToTerms = false;
  bool _isInitialLoading = true;
  bool _isApplyingCoupon = false;
  bool _isSubmittingCheckout = false;

  @override
  void initState() {
    super.initState();
    _cartStore = GetIt.instance<CartStore>();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    setState(() {
      _isInitialLoading = true;
    });

    try {
      await _cartStore.loadCart();
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _handleRemoveItem(String itemId) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.hideCurrentSnackBar();

    await _cartStore.removeItemFromCart(itemId);

    if (!mounted) return;

    if (_cartStore.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_cartStore.errorMessage!),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: const Text('Item removed from cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _handleQuantityChange(String itemId, int newQuantity) async {
    if (newQuantity <= 0) return;

    await _cartStore.updateItemQuantity(itemId, newQuantity);

    if (!mounted) return;

    if (_cartStore.errorMessage != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cartStore.errorMessage!),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
  }

  Future<void> _handleApplyCoupon(String couponCode) async {
    setState(() {
      _isApplyingCoupon = true;
    });

    await _cartStore.applyCoupon(couponCode);

    if (!mounted) return;

    setState(() {
      _isApplyingCoupon = false;
    });

    ScaffoldMessenger.of(context).clearSnackBars();

    if (_cartStore.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cartStore.errorMessage!),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon applied successfully'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleRemoveCoupon() async {
    await _cartStore.removeCoupon();

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    if (_cartStore.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cartStore.errorMessage!),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon removed'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleContinueShopping() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/products',
      (route) => false,
    );
  }

  Future<void> _handleApproveCheckout() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to terms and conditions'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_cartStore.checkoutItems.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item to checkout'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_cartStore.isCartValid) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some selected items exceed available stock'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingCheckout = true;
    });

    try {
      Navigator.of(context).pushNamed(
        '/checkout',
        arguments: {
          'paymentMethod': _selectedPaymentMethod,
          'cartData': _cartStore.checkoutData,
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingCheckout = false;
        });
      }
    }
  }

  bool get _allItemsSelected =>
      _cartStore.cart.items.isNotEmpty &&
      _cartStore.selectedItemIds.length == _cartStore.cart.items.length;

  void _selectAllItems() {
    setState(() {
      if (_allItemsSelected) {
        _cartStore.clearSelection();
      } else {
        _cartStore.selectAllItems();
      }
    });
  }

  bool get _canCheckout =>
      _selectedPaymentMethod != null &&
      _agreeToTerms &&
      _cartStore.checkoutItems.isNotEmpty &&
      _cartStore.isCartValid &&
      !_isSubmittingCheckout;

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
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cartStore.errorMessage != null && _cartStore.isEmpty) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 12, 24),
                  child: _buildLeftContent(cartUIModel),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      left: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 20, 20, 24),
                    child: _buildRightContent(cartUIModel),
                  ),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeftContent(cartUIModel),
              const SizedBox(height: 24),
              _buildRightContent(cartUIModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeftContent(CartUIModel cartUIModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCartItemsSection(cartUIModel),
      ],
    );
  }

  Widget _buildRightContent(CartUIModel cartUIModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CouponFormWidget(
          onApplyCoupon: _handleApplyCoupon,
          onRemoveCoupon: _handleRemoveCoupon,
          appliedCouponCode: _cartStore.appliedCouponCode,
          isLoading: _isApplyingCoupon,
          error: null,
          success: null,
        ),
        const SizedBox(height: 24),
        Observer(
          builder: (_) => PriceSummaryCard(
            subtotal: _cartStore.selectedSubtotal,
            discountAmount: _cartStore.selectedDiscountAmount,
            taxAmount: _cartStore.selectedTaxAmount,
            shippingAmount: _cartStore.selectedShippingAmount,
            total: _cartStore.selectedTotal,
            discountLabel: cartUIModel.appliedCoupon != null
                ? 'Coupon (${cartUIModel.appliedCoupon!.code})'
                : 'Discount',
            showDividers: true,
          ),
        ),
        const SizedBox(height: 24),
        PaymentMethodsWidget(
          onMethodSelected: (method) {
            setState(() => _selectedPaymentMethod = method);
          },
          selectedMethod: _selectedPaymentMethod,
          showSavedCards: true,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
          ),
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
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canCheckout ? _handleApproveCheckout : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmittingCheckout
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _cartStore.isCartValid
                        ? 'Proceed to Checkout'
                        : 'Selected items are invalid',
                    style: TextStyle(
                      color: _canCheckout ? Colors.white : Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
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
        const SizedBox(height: 8),
        if (_cartStore.checkoutItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Selected: ${_cartStore.checkoutItems.length} item(s)',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCartItemsSection(CartUIModel cartUIModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          runSpacing: 8,
          spacing: 8,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Items in Cart',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (cartUIModel.itemCount > 0)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _selectAllItems,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    _allItemsSelected ? 'Deselect All' : 'Select All',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cartUIModel.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = cartUIModel.items[index];
            return Observer(
              builder: (_) => CartItemCard(
                key: ValueKey('cart_item_${item.id}'),
                item: item,
                isSelected: _cartStore.selectedItemIds.contains(item.id),
                onSelectChanged: (isSelected) {
                  _cartStore.toggleItemSelection(item.id);
                },
                onRemove: () => _handleRemoveItem(item.id),
                onQuantityChanged: (newQuantity) =>
                    _handleQuantityChange(item.id, newQuantity),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
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
                textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}

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
        return Builder(
          builder: (innerContext) => Scaffold(
            body: const CartScreen(),
            endDrawer: cartUIModel.isEmpty
                ? null
                : MiniCartDrawer(
                    cartData: cartUIModel,
                    onViewFullCart: () => Navigator.pop(innerContext),
                    onCheckout: _handleCheckout,
                    onRemoveItem: (itemId) async {
                      await _cartStore.removeItemFromCart(itemId);
                      if (mounted) setState(() {});
                    },
                    onQuantityChanged: (itemId, quantity) async {
                      await _cartStore.updateItemQuantity(itemId, quantity);
                      if (mounted) setState(() {});
                    },
                    isLoading: false,
                    onDrawerToggle: () {
                      final scaffoldState = Scaffold.maybeOf(innerContext);
                      if (scaffoldState == null) return;

                      if (scaffoldState.isEndDrawerOpen) {
                        Navigator.pop(innerContext);
                      } else {
                        scaffoldState.openEndDrawer();
                      }
                    },
                  ),
          ),
        );
      },
    );
  }

  void _handleCheckout() {
    Navigator.pop(context);
    Navigator.of(context).pushNamed(
      '/checkout',
      arguments: {
        'cartData': _cartStore.checkoutData,
      },
    );
  }
}
