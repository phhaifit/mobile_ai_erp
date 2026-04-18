import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_calculation.dart';
import 'package:mobile_ai_erp/presentation/cart/models/cart_ui_model.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/cart_item_card.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/coupon_form_widget.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/empty_cart_state.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/mini_cart_drawer.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/price_summary_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartStore _cartStore;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isInitialLoading = true;
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
      await _cartStore.loadCoupons();
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
      const SnackBar(
        content: Text('Item removed from cart'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
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
    }
  }

  Future<void> _handleApplyCoupon(String code) async {
    if (_cartStore.checkoutItems.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one item before applying a coupon',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await _cartStore.validateAndApplyCoupon(code);

    if (!mounted) return;

    if (_cartStore.errorMessage != null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cartStore.errorMessage!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleRemoveCoupon() async {
    await _cartStore.clearSelectedCoupon();
  }

  void _handleContinueShopping() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/products', (route) => false);
  }

  Future<void> _handleApproveCheckout() async {
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
          content: Text('Selected items are invalid'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingCheckout = true;
    });

    try {
      if (_cartStore.calculation == null) {
        await _cartStore.calculateSelectedCart();
      }

      if (!mounted) return;

      Navigator.of(context).pushNamed(
        '/checkout',
        arguments: {
          'cartId': _cartStore.cart.id,
          'customerId': _cartStore.cart.customerId,
          'tenantId': _cartStore.cart.tenantId,
          'selectedItemIds': _cartStore.selectedItemIds.toList(),
          'calculation': _cartStore.calculation,
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
    if (_allItemsSelected) {
      _cartStore.clearSelection();
    } else {
      _cartStore.selectAllItems();
    }
  }

  bool get _canCheckout =>
      _cartStore.checkoutItems.isNotEmpty &&
      _cartStore.isCartValid &&
      !_isSubmittingCheckout;

  CartCalculationSummary _fallbackSummary() {
    final selectedQuantity = _cartStore.checkoutItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    final selectedSubtotal = _cartStore.checkoutItems.fold<int>(
      0,
      (sum, item) => sum + int.parse(item.lineTotal),
    );

    return CartCalculationSummary(
      subtotal: selectedSubtotal.toString(),
      discount: '0',
      total: selectedSubtotal.toString(),
      selectedItemsCount: _cartStore.checkoutItems.length,
      selectedQuantity: selectedQuantity,
    );
  }

  String? get _couponError {
    if (_cartStore.couponValidationError != null &&
        _cartStore.couponValidationError!.isNotEmpty) {
      return _cartStore.couponValidationError;
    }

    final coupon = _cartStore.calculation?.coupon;
    if (coupon == null) return null;
    if (coupon.isValid) return null;
    return coupon.reason ?? 'Coupon is invalid';
  }

  String? get _couponSuccess {
    final validated = _cartStore.validatedCoupon;
    if (validated != null && validated.isValid) {
      final promotionName = validated.promotion?.name;
      return (promotionName != null && promotionName.isNotEmpty)
          ? '$promotionName applied successfully'
          : 'Coupon applied successfully';
    }

    final coupon = _cartStore.calculation?.coupon;
    if (coupon == null) return null;
    if (!coupon.isApplied || !coupon.isValid) return null;

    return coupon.name != null
        ? '${coupon.name} applied successfully'
        : 'Coupon applied successfully';
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final cartUIModel = CartUIModel(
          cart: _cartStore.cart,
          calculation: _cartStore.calculation,
        );

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Shopping Cart'),
            elevation: 0,
            centerTitle: true,
            actions: [
              if (_cartStore.cartBadgeCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    child: Text(
                      '${_cartStore.cartBadgeCount} item${_cartStore.cartBadgeCount != 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              MiniCartBadge(
                itemCount: _cartStore.cartBadgeCount,
                hasDiscount: _cartStore.calculation?.coupon?.isApplied ?? false,
                onTap: () {
                  if (_cartStore.isEmpty) return;
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          endDrawer: cartUIModel.isEmpty
              ? null
              : MiniCartDrawer(
                  cartData: cartUIModel,
                  onViewFullCart: () => Navigator.pop(context),
                  onCheckout: _handleApproveCheckout,
                  onRemoveItem: (itemId) async {
                    await _handleRemoveItem(itemId);
                  },
                  onQuantityChanged: (itemId, quantity) async {
                    await _handleQuantityChange(itemId, quantity);
                  },
                  isLoading: _cartStore.isLoading,
                  onDrawerToggle: () {
                    if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
                      Navigator.pop(context);
                    } else {
                      _scaffoldKey.currentState?.openEndDrawer();
                    }
                  },
                ),
          body: _buildBody(cartUIModel),
        );
      },
    );
  }

  Widget _buildBody(CartUIModel cartUIModel) {
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
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.5),
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
      children: [_buildCartItemsSection(cartUIModel)],
    );
  }

  Widget _buildRightContent(CartUIModel cartUIModel) {
    final summary = _cartStore.calculation?.summary ?? _fallbackSummary();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CouponFormWidget(
          coupons: _cartStore.availableCoupons.toList(),
          onApplyCoupon: _handleApplyCoupon,
          onRemoveCoupon: _handleRemoveCoupon,
          appliedCouponCode: _cartStore.calculation?.coupon?.isApplied == true
              ? _cartStore.calculation?.coupon?.code
              : _cartStore.selectedCouponCode,
          isLoading: _cartStore.isLoading || _cartStore.isLoadingCoupons,
          error: _couponError,
          success: _couponSuccess,
        ),
        const SizedBox(height: 16),
        PriceSummaryCard(
          summary: summary,
          coupon: _cartStore.calculation?.coupon,
          discountLabel: 'Discount',
          showDividers: true,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: Observer(
            builder: (_) => ElevatedButton(
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
        Observer(
          builder: (_) => _cartStore.checkoutItems.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Selected: ${_cartStore.checkoutItems.length} item(s)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
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
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (cartUIModel.cart.totalItems > 0)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _selectAllItems,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
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
          itemCount: cartUIModel.cart.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = cartUIModel.cart.items[index];
            return Observer(
              builder: (_) => CartItemCard(
                key: ValueKey('cart_item_${item.id}'),
                item: item,
                isSelected: _cartStore.selectedItemIds.contains(item.id),
                onSelectChanged: (isSelected) {
                  _cartStore.toggleItemSelection(item.id);
                },
                onRemove: () => _handleRemoveItem(item.id),
                onMoveToWishlist: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  await _cartStore.moveCartItemToWishlist(item);

                  if (!mounted) return;

                  if (_cartStore.errorMessage != null) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(_cartStore.errorMessage!)),
                    );
                    return;
                  }

                  messenger.showSnackBar(
                    const SnackBar(content: Text('Moved to wishlist')),
                  );
                },
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
              Icon(Icons.error_outline, size: 64, color: Colors.red[600]),
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

class CartScreenWithDrawer extends StatelessWidget {
  const CartScreenWithDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CartScreen();
  }
}
