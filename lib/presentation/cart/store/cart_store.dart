import 'package:mobile_ai_erp/data/repository/product/product_repository.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';
import 'package:mobile_ai_erp/domain/entity/product_detail/product_detail.dart';
import 'package:mobile_ai_erp/presentation/cart/store/wishlist_store.dart';
import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/coupon.dart';
import 'package:uuid/uuid.dart';

part 'cart_store.g.dart';

class CartStore = CartStoreBase with _$CartStore;

abstract class CartStoreBase with Store {
  final CartRepository _cartRepository;
  final ProductRepository _productRepository;
  final WishlistStore _wishlistStore;
  final String userId;
  final Uuid _uuid = const Uuid();

  @observable
  late Cart cart;

  CartStoreBase({
    required CartRepository cartRepository,
    required ProductRepository productRepository,
    required WishlistStore wishlistStore,
    required this.userId,
  }) : _cartRepository = cartRepository,
       _productRepository = productRepository,
       _wishlistStore = wishlistStore {
    cart = Cart(id: 'cart_$userId', userId: userId, items: const []);
    loadCart();
  }

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isCartDrawerOpen = false;

  @observable
  String cartFilterBy = 'all';

  @observable
  String searchQuery = '';

  @observable
  ObservableList<String> selectedItemIds = ObservableList<String>();

  @computed
  int get itemCount => cart.itemCount;

  @computed
  int get uniqueItemCount => cart.uniqueItemCount;

  @computed
  double get subtotal => cart.subtotal;

  @computed
  double get discountAmount => cart.cartLevelDiscount;

  @computed
  double get taxAmount => cart.taxAmount;

  @computed
  double get shippingAmount => cart.shippingAmount;

  @computed
  double get total => cart.total;

  @computed
  double get savingsAmount => cart.savingsAmount;

  @computed
  double get savingsPercent => cart.savingsPercentage;

  @computed
  bool get isEmpty => cart.isEmpty;

  @computed
  bool get hasLowStockItems => cart.hasLowStockItems;

  @computed
  bool get hasOutOfStockItems => cart.hasOutOfStockItems;

  @computed
  List<CartItem> get outOfStockItems => cart.outOfStockItems;

  @computed
  List<CartItem> get lowStockItems => cart.lowStockItems;

  @computed
  bool get hasCoupon => cart.hasCoupon;

  @computed
  String? get appliedCouponCode => cart.appliedCoupon?.code;

  @computed
  int get selectedItemsCount => selectedItemIds.length;

  /// Selected items for checkout.
  /// If no items are selected, returns an empty list.
  @computed
  List<CartItem> get checkoutItems {
    return cart.items
        .where((item) => selectedItemIds.contains(item.id))
        .toList();
  }

  /// Disable checkout if any checkout item exceeds available stock.
  @computed
  bool get isCartValid {
    if (checkoutItems.isEmpty) return false;

    return checkoutItems.every((item) {
      if (item.stockAvailable == null) return true;
      return item.quantity <= item.stockAvailable!;
    });
  }

  @computed
  double get selectedSubtotal {
    return checkoutItems.fold<double>(0, (sum, item) => sum + item.subtotal);
  }

  @computed
  double get selectedDiscountAmount {
    if (!hasCoupon || cart.subtotal <= 0 || selectedSubtotal <= 0) return 0.0;
    return (selectedSubtotal / cart.subtotal) * cart.cartLevelDiscount;
  }

  @computed
  double get selectedTaxAmount {
    final taxableAmount = selectedSubtotal - selectedDiscountAmount;
    if (cart.taxPercentage == null || cart.taxPercentage == 0) return 0.0;
    return (taxableAmount * cart.taxPercentage!) / 100;
  }

  @computed
  double get selectedShippingAmount {
    if (checkoutItems.isEmpty) return 0.0;

    final allSelected =
        selectedItemIds.isNotEmpty &&
        selectedItemIds.length == cart.items.length;

    return allSelected ? cart.shippingAmount : 0.0;
  }

  @computed
  double get selectedTotal {
    return selectedSubtotal -
        selectedDiscountAmount +
        selectedTaxAmount +
        selectedShippingAmount;
  }

  /// Clean payload for Checkout team
  @computed
  Map<String, dynamic> get checkoutData {
    final items = checkoutItems
        .map(
          (item) => {
            'cartItemId': item.id,
            'productId': item.productId,
            'productName': item.productName,
            'variantId': item.variantId,
            'sku': item.sku,
            'size': item.selectedSize,
            'colorName': item.selectedColorName,
            'unitPrice': item.effectivePrice,
            'originalUnitPrice': item.price,
            'quantity': item.quantity,
            'availableStock': item.stockAvailable,
            'lineTotal': item.subtotal,
            'imageUrl': item.imageUrl,
          },
        )
        .toList();

    return {
      'cartId': cart.id,
      'userId': cart.userId,
      'isValid': isCartValid,
      'itemCount': checkoutItems.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      ),
      'uniqueItemCount': checkoutItems.length,
      'couponCode': cart.appliedCoupon?.code,
      'pricing': {
        'subtotal': selectedSubtotal,
        'discount': selectedDiscountAmount,
        'tax': selectedTaxAmount,
        'shipping': selectedShippingAmount,
        'total': selectedTotal,
      },
      'items': items,
    };
  }

  @computed
  List<CartItem> get filteredItems {
    var filtered = cart.items;

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (item) => item.productName.toLowerCase().contains(
              searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    if (cartFilterBy == 'low-stock') {
      filtered = filtered.where((item) => item.isLowStock).toList();
    } else if (cartFilterBy == 'on-sale') {
      filtered = filtered.where((item) => item.hasDiscount).toList();
    }

    return filtered;
  }

  @action
  Future<void> loadCart() async {
    isLoading = true;
    errorMessage = null;

    try {
      final result = await _cartRepository.getCart(userId);
      cart = result;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  /// New flow:
  /// addToCart(variantId, qty)
  /// -> get variant detail from ProductRepository
  /// -> build CartItem from ProductVariant
  /// -> save to cart
  @action
  Future<void> addToCart(String variantId, int qty) async {
    if (qty <= 0) {
      errorMessage = 'Quantity must be greater than 0';
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      final variantDetail = await _productRepository.getVariantDetail(
        variantId,
      );

      final item = CartItem.fromVariant(
        productId: variantDetail.productId,
        productName: variantDetail.productName,
        variant: variantDetail.variant,
        imageUrl: variantDetail.imageUrl,
        quantity: qty,
      ).copyWith(id: 'item_${_uuid.v4()}');

      await _cartRepository.addItemToCart(userId, item);
      cart = await _cartRepository.getCart(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addVariantToCart({
    required String productId,
    required String productName,
    required ProductVariant variant,
    String? imageUrl,
    int qty = 1,
  }) async {
    if (qty <= 0) {
      errorMessage = 'Quantity must be greater than 0';
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      final item = CartItem.fromVariant(
        productId: productId,
        productName: productName,
        variant: variant,
        imageUrl: imageUrl,
        quantity: qty,
      ).copyWith(id: 'item_${_uuid.v4()}');

      await _cartRepository.addItemToCart(userId, item);
      cart = await _cartRepository.getCart(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  /// Keep this method in case some screen already builds CartItem manually
  @action
  Future<void> addItemToCart(CartItem item) async {
    isLoading = true;
    errorMessage = null;

    try {
      final normalizedItem = item.id.isEmpty
          ? item.copyWith(id: 'item_${_uuid.v4()}')
          : item;

      await _cartRepository.addItemToCart(userId, normalizedItem);
      cart = await _cartRepository.getCart(userId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addMultipleItemsToCart(List<CartItem> items) async {
    isLoading = true;
    errorMessage = null;

    try {
      final itemsWithIds = items
          .map(
            (item) => item.id.isEmpty
                ? item.copyWith(id: 'item_${_uuid.v4()}')
                : item,
          )
          .toList();

      await _cartRepository.addMultipleItemsToCart(userId, itemsWithIds);
      await loadCart();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> removeItemFromCart(String itemId) async {
    isLoading = true;
    errorMessage = null;

    try {
      await _cartRepository.removeItemFromCart(userId, itemId);
      await loadCart();
      selectedItemIds.remove(itemId);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> removeMultipleItemsFromCart(List<String> itemIds) async {
    isLoading = true;
    errorMessage = null;

    try {
      await _cartRepository.removeMultipleItemsFromCart(userId, itemIds);
      await loadCart();
      selectedItemIds.clear();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> removeSelectedItems() async {
    if (selectedItemIds.isEmpty) return;
    await removeMultipleItemsFromCart(List.from(selectedItemIds));
  }

  @action
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    isLoading = true;
    errorMessage = null;

    try {
      await _cartRepository.updateItemQuantity(userId, itemId, newQuantity);
      await loadCart();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> incrementItemQuantity(String itemId) async {
    final item = cart.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );
    await updateItemQuantity(itemId, item.quantity + 1);
  }

  @action
  Future<void> decrementItemQuantity(String itemId) async {
    final item = cart.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    if (item.quantity <= 1) {
      await removeItemFromCart(itemId);
    } else {
      await updateItemQuantity(itemId, item.quantity - 1);
    }
  }

  @action
  Future<void> applyCoupon(String couponCode) async {
    isLoading = true;
    errorMessage = null;

    try {
      await _cartRepository.applyCoupon(userId, couponCode);
      await loadCart();
    } catch (e) {
      errorMessage = 'Invalid coupon: ${e.toString()}';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> removeCoupon() async {
    isLoading = true;
    errorMessage = null;

    try {
      await _cartRepository.removeCoupon(userId);
      await loadCart();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> clearCart() async {
    isLoading = true;
    errorMessage = null;

    try {
      await _cartRepository.clearCart(userId);
      await loadCart();
      selectedItemIds.clear();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void toggleCartDrawer() {
    isCartDrawerOpen = !isCartDrawerOpen;
  }

  @action
  void openCartDrawer() {
    isCartDrawerOpen = true;
  }

  @action
  void closeCartDrawer() {
    isCartDrawerOpen = false;
  }

  @action
  void toggleItemSelection(String itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
    }
  }

  @action
  void selectAllItems() {
    selectedItemIds
      ..clear()
      ..addAll(cart.items.map((item) => item.id));
  }

  @action
  void clearSelection() {
    selectedItemIds.clear();
  }

  @action
  void updateSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  void updateFilter(String filter) {
    cartFilterBy = filter;
  }

  @action
  Future<List<String>> validateCartForCheckout() async {
    try {
      return await _cartRepository.validateCartForCheckout(userId);
    } catch (e) {
      errorMessage = e.toString();
      return ['Validation error: ${e.toString()}'];
    }
  }

  @action
  Future<List<Coupon>> getAvailableCoupons() async {
    try {
      return await _cartRepository.getAvailableCoupons(userId: userId);
    } catch (e) {
      errorMessage = e.toString();
      return [];
    }
  }

  @action
  Future<void> syncCart() async {
    isLoading = true;
    errorMessage = null;

    try {
      await _cartRepository.syncCartWithServer(userId);
      await loadCart();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<Map<String, dynamic>> getCartStats() async {
    try {
      return await _cartRepository.getCartStatistics(userId);
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  Future<void> initialize() async {
    await loadCart();
  }

  @action
  void dispose() {
    clearSelection();
    closeCartDrawer();
    clearError();
  }

  WishlistItem _mapCartItemToWishlistItem(CartItem item) {
    return WishlistItem(
      id: 'wishlist_${item.id}',
      productId: item.productId,
      productName: item.productName,
      imageUrl: item.imageUrl,
      variantId: item.variantId,
      sku: item.sku,
      selectedSize: item.selectedSize,
      selectedColorName: item.selectedColorName,
      selectedColorValue: item.selectedColorValue,
      price: item.price,
      salePrice: item.salePrice,
      stockAvailable: item.stockAvailable,
      dateAdded: DateTime.now(),
    );
  }

  CartItem _mapWishlistItemToCartItem(WishlistItem item) {
    return CartItem(
      id: '${item.productId}_${item.variantId}',
      productId: item.productId,
      productName: item.productName,
      imageUrl: item.imageUrl,
      variantId: item.variantId,
      sku: item.sku,
      selectedSize: item.selectedSize,
      selectedColorName: item.selectedColorName,
      selectedColorValue: item.selectedColorValue,
      price: item.price,
      salePrice: item.salePrice,
      stockAvailable: item.stockAvailable,
      quantity: 1,
      isSelected: false,
    );
  }

  @action
  Future<void> moveCartItemToWishlist(CartItem item) async {
    isLoading = true;
    errorMessage = null;

    try {
      final wishlistItem = _mapCartItemToWishlistItem(item);

      if (!_wishlistStore.containsVariant(item.variantId)) {
        await _wishlistStore.addToWishlist(wishlistItem);
      }

      await removeItemFromCart(item.id);
      selectedItemIds.remove(item.id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> moveWishlistItemToCart(WishlistItem item) async {
    isLoading = true;
    errorMessage = null;

    try {
      if (item.isOutOfStock) {
        throw Exception('Item is out of stock');
      }

      final cartItem = _mapWishlistItemToCartItem(item);

      await addItemToCart(cartItem);
      await _wishlistStore.removeFromWishlist(item);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }
}
