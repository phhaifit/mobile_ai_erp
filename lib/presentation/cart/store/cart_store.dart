import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/coupon.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:uuid/uuid.dart';

part 'cart_store.g.dart';

class CartStore = CartStoreBase with _$CartStore;

abstract class CartStoreBase with Store {
  final CartRepository _cartRepository;
  final String userId;

  @observable
  late Cart cart;

  CartStoreBase({
    required CartRepository cartRepository,
    required this.userId,
  }) : _cartRepository = cartRepository {
    cart = Cart(
      id: 'cart_$userId',
      userId: userId,
      items: [],
    );
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
  List<String> selectedItemIds = [];

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

  @computed
  List<CartItem> get filteredItems {
    var filtered = cart.items;

    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((item) => item.productName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (cartFilterBy == 'low-stock') {
      filtered = filtered.where((item) => item.isLowStock).toList();
    } else if (cartFilterBy == 'on-sale') {
      filtered = filtered.where((item) => item.itemDiscount != null).toList();
    }

    return filtered;
  }

  @action
  Future<void> loadCart() async {
    isLoading = true;
    try {
      final result = await _cartRepository.getCart(userId);
      cart = result;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addItemToCart(CartItem item) async {
    isLoading = true;
    errorMessage = null;

    try {
      print('1. Bắt đầu thêm sản phẩm: ${item.productName}');
      await _cartRepository.addItemToCart(userId, item);
      print('2. Repository đã báo lưu xong');

      // --- SỬA/THÊM DÒNG NÀY ---
      final updatedCart = await _cartRepository.getCart(userId);
      cart = updatedCart;
      // -------------------------

      print('STORE items.length = ${cart.items.length}');
      for (final e in cart.items) {
        print('STORE item: ${e.productName}, qty=${e.quantity}');
      }
      print('STORE itemCount = ${cart.itemCount}');
      print('STORE isEmpty = ${cart.isEmpty}');
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  /// Add multiple items to cart
  @action
  Future<void> addMultipleItemsToCart(List<CartItem> items) async {
    isLoading = true;
    errorMessage = null;

    try {
      final itemsWithIds = items
          .map((item) => item.id.isEmpty
              ? item.copyWith(id: 'item_${const Uuid().v4()}')
              : item)
          .toList();

      await _cartRepository.addMultipleItemsToCart(userId, itemsWithIds);
      await loadCart();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  /// Remove item from cart
  @action
  Future<void> removeItemFromCart(String itemId) async {
    isLoading = true;
    errorMessage = null;

    try {
      await _cartRepository.removeItemFromCart(userId, itemId);
      await loadCart();
      selectedItemIds.remove(itemId); // Remove from selected if was selected
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  /// Remove multiple items from cart
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

  /// Remove all selected items
  @action
  Future<void> removeSelectedItems() async {
    if (selectedItemIds.isEmpty) return;
    await removeMultipleItemsFromCart(List.from(selectedItemIds));
  }

  /// Update item quantity
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

  /// Increment item quantity
  @action
  Future<void> incrementItemQuantity(String itemId) async {
    final item = cart.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );
    await updateItemQuantity(itemId, item.quantity + 1);
  }

  /// Decrement item quantity
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

  /// Apply coupon code
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

  /// Remove applied coupon
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

  /// Clear entire cart
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

  /// Toggle cart drawer open/close
  @action
  void toggleCartDrawer() {
    isCartDrawerOpen = !isCartDrawerOpen;
  }

  /// Open cart drawer
  @action
  void openCartDrawer() {
    isCartDrawerOpen = true;
  }

  /// Close cart drawer
  @action
  void closeCartDrawer() {
    isCartDrawerOpen = false;
  }

  /// Toggle item selection
  @action
  void toggleItemSelection(String itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
    }
  }

  /// Select all items
  @action
  void selectAllItems() {
    selectedItemIds = cart.items.map((item) => item.id).toList();
  }

  /// Clear selection
  @action
  void clearSelection() {
    selectedItemIds.clear();
  }

  /// Update search query
  @action
  void updateSearchQuery(String query) {
    searchQuery = query;
  }

  /// Update filter
  @action
  void updateFilter(String filter) {
    cartFilterBy = filter;
  }

  /// Validate cart before checkout
  @action
  Future<List<String>> validateCartForCheckout() async {
    try {
      return await _cartRepository.validateCartForCheckout(userId);
    } catch (e) {
      errorMessage = e.toString();
      return ['Validation error: ${e.toString()}'];
    }
  }

  /// Get available coupons
  @action
  Future<List<Coupon>> getAvailableCoupons() async {
    try {
      return await _cartRepository.getAvailableCoupons();
    } catch (e) {
      errorMessage = e.toString();
      return [];
    }
  }

  /// Sync cart with server
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

  /// Get cart statistics
  @action
  Future<Map<String, dynamic>> getCartStats() async {
    try {
      return await _cartRepository.getCartStatistics(userId);
    } catch (e) {
      errorMessage = e.toString();
      return {};
    }
  }

  /// Clear error message
  @action
  void clearError() {
    errorMessage = null;
  }

  /// Initialize/reset store - call in initState
  @action
  Future<void> initialize() async {
    await loadCart();
  }

  /// Dispose/cleanup - call in dispose
  @action
  void dispose() {
    clearSelection();
    closeCartDrawer();
    clearError();
  }
}
