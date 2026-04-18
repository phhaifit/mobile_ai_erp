import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:mobile_ai_erp/data/repository/coupon/coupon_repository.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_calculation.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/coupon/coupon.dart';
import 'package:mobile_ai_erp/domain/entity/coupon/validated_coupon.dart';
import 'package:mobile_ai_erp/presentation/cart/store/wishlist_store.dart';

part 'cart_store.g.dart';

class CartStore = CartStoreBase with _$CartStore;

abstract class CartStoreBase with Store {
  final CartRepository _cartRepository;
  final CouponRepository _couponRepository;
  final WishlistStore _wishlistStore;
  final String customerId;
  final String tenantId;

  CartStoreBase({
    required CartRepository cartRepository,
    required CouponRepository couponRepository,
    required WishlistStore wishlistStore,
    required this.customerId,
    required this.tenantId,
  }) : _cartRepository = cartRepository,
       _couponRepository = couponRepository,
       _wishlistStore = wishlistStore {
    cart = Cart(
      id: 'cart_$customerId',
      tenantId: tenantId,
      customerId: customerId,
      subtotal: '0',
      totalItems: 0,
      items: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @observable
  late Cart cart;

  @observable
  CartCalculation? calculation;

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

  @observable
  ObservableList<Coupon> availableCoupons = ObservableList<Coupon>();

  @observable
  bool isLoadingCoupons = false;

  @observable
  String? selectedCouponCode;

  @observable
  String? couponValidationError;

  @observable
  ValidatedCoupon? validatedCoupon;

  @observable
  Map<String, dynamic>? cartSummary;

  @computed
  int get itemCount => cart.totalItems;

  @computed
  bool get isEmpty => cart.items.isEmpty;

  @computed
  bool get hasLowStockItems => cart.items.any((item) => item.stockWarning);

  @computed
  bool get hasOutOfStockItems => cart.items.any((item) => !item.isAvailable);

  @computed
  List<CartItem> get outOfStockItems =>
      cart.items.where((item) => !item.isAvailable).toList();

  @computed
  List<CartItem> get lowStockItems =>
      cart.items.where((item) => item.stockWarning).toList();

  @computed
  bool get hasCoupon => calculation?.coupon != null;

  @computed
  String? get appliedCouponCode =>
      calculation?.coupon?.code ?? selectedCouponCode;

  @computed
  int get selectedItemsCount => selectedItemIds.length;

  @computed
  int get cartBadgeCount =>
      (cartSummary?['totalItems'] as num?)?.toInt() ?? cart.totalItems;

  @computed
  int get distinctItemsCount =>
      (cartSummary?['distinctItems'] as num?)?.toInt() ?? cart.items.length;

  @computed
  bool get hasSelectedCoupon =>
      selectedCouponCode != null && selectedCouponCode!.isNotEmpty;

  @computed
  List<CartItem> get checkoutItems {
    return cart.items
        .where((item) => selectedItemIds.contains(item.id))
        .toList();
  }

  @computed
  bool get isCartValid =>
      checkoutItems.isNotEmpty &&
      checkoutItems.every((item) => item.isAvailable);

  @computed
  String get selectedSubtotal =>
      calculation?.summary.subtotal ?? _sumSelectedLineTotals();

  @computed
  String get selectedDiscountAmount => calculation?.summary.discount ?? '0';

  @computed
  String get selectedTotal =>
      calculation?.summary.total ?? _sumSelectedLineTotals();

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
      filtered = filtered.where((item) => item.stockWarning).toList();
    } else if (cartFilterBy == 'unavailable') {
      filtered = filtered.where((item) => !item.isAvailable).toList();
    }

    return filtered;
  }

  String _sumSelectedLineTotals() {
    final total = checkoutItems.fold<int>(
      0,
      (sum, item) => sum + int.parse(item.lineTotal),
    );
    return total.toString();
  }

  @action
  Future<void> loadCart() async {
    isLoading = true;
    errorMessage = null;

    try {
      final result = await _cartRepository.getCart(
        customerId: customerId,
        tenantId: tenantId,
      );
      cart = result;
      await loadCartSummary();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadCartSummary() async {
    try {
      cartSummary = await _cartRepository.getCartSummary(
        customerId: customerId,
        tenantId: tenantId,
      );
    } catch (_) {}
  }

  @action
  Future<void> loadCoupons() async {
    isLoadingCoupons = true;
    couponValidationError = null;

    try {
      final result = await _couponRepository.getCoupons(tenantId: tenantId);
      availableCoupons = ObservableList<Coupon>.of(result);
    } catch (e) {
      couponValidationError = e.toString();
    } finally {
      isLoadingCoupons = false;
    }
  }

  @action
  Future<void> addToCart({
    required String productId,
    String? variantId,
    int qty = 1,
  }) async {
    if (qty <= 0) {
      errorMessage = 'Quantity must be greater than 0';
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      cart = await _cartRepository.addCartItem(
        customerId: customerId,
        tenantId: tenantId,
        productId: productId,
        variantId: variantId,
        quantity: qty,
      );
      await loadCartSummary();
      await _wishlistStore.loadWishlist();
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
      cart = await _cartRepository.removeCartItem(
        customerId: customerId,
        tenantId: tenantId,
        itemId: itemId,
      );
      selectedItemIds.remove(itemId);
      calculation = null;
      await loadCartSummary();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItemFromCart(itemId);
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      cart = await _cartRepository.updateCartItemQuantity(
        customerId: customerId,
        tenantId: tenantId,
        itemId: itemId,
        quantity: newQuantity,
      );
      calculation = null;
      await loadCartSummary();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> removeMultipleItemsFromCart(List<String> itemIds) async {
    if (itemIds.isEmpty) return;

    isLoading = true;
    errorMessage = null;

    try {
      for (final itemId in itemIds) {
        cart = await _cartRepository.removeCartItem(
          customerId: customerId,
          tenantId: tenantId,
          itemId: itemId,
        );
        selectedItemIds.remove(itemId);
      }
      calculation = null;
      await loadCartSummary();
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
  Future<void> calculateSelectedCart({String? couponCode}) async {
    if (selectedItemIds.isEmpty) {
      calculation = null;
      return;
    }

    isLoading = true;
    errorMessage = null;

    try {
      calculation = await _cartRepository.calculateCart(
        customerId: customerId,
        tenantId: tenantId,
        selectedItemIds: selectedItemIds.toList(),
        couponCode: couponCode ?? selectedCouponCode,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> validateAndApplyCoupon(String code) async {
    couponValidationError = null;
    validatedCoupon = null;

    if (checkoutItems.isEmpty) {
      couponValidationError = 'Please select at least one item first';
      return;
    }

    final subtotal = checkoutItems.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.lineTotal) ?? 0),
    );

    try {
      final result = await _couponRepository.validateCoupon(
        tenantId: tenantId,
        couponCode: code,
        subtotal: subtotal,
      );

      validatedCoupon = result;

      if (!result.isValid) {
        selectedCouponCode = null;
        couponValidationError = result.reason ?? 'Coupon is invalid';
        await calculateSelectedCart();
        return;
      }

      selectedCouponCode = code;
      await calculateSelectedCart(couponCode: code);
    } catch (e) {
      couponValidationError = e.toString();
    }
  }

  @action
  Future<void> clearSelectedCoupon() async {
    selectedCouponCode = null;
    couponValidationError = null;
    validatedCoupon = null;

    if (selectedItemIds.isEmpty) {
      calculation = null;
      return;
    }

    await calculateSelectedCart();
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
    calculation = null;
    couponValidationError = null;
    validatedCoupon = null;
  }

  @action
  void selectAllItems() {
    selectedItemIds
      ..clear()
      ..addAll(cart.items.map((item) => item.id));
    calculation = null;
    couponValidationError = null;
    validatedCoupon = null;
  }

  @action
  void clearSelection() {
    selectedItemIds.clear();
    calculation = null;
    selectedCouponCode = null;
    couponValidationError = null;
    validatedCoupon = null;
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
  Future<void> moveCartItemToWishlist(CartItem item) async {
    isLoading = true;
    errorMessage = null;

    try {
      if (!_wishlistStore.containsItem(item.productId, item.variantId)) {
        await _wishlistStore.addToWishlist(
          productId: item.productId,
          variantId: item.variantId,
        );
      }

      await loadCart();
      selectedItemIds.remove(item.id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
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
}
