import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_calculation.dart';
import 'package:mobile_ai_erp/domain/entity/cart/cart_item.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';
import 'package:mobile_ai_erp/presentation/cart/store/wishlist_store.dart';

part 'cart_store.g.dart';

class CartStore = CartStoreBase with _$CartStore;

abstract class CartStoreBase with Store {
  final CartRepository _cartRepository;
  final WishlistStore _wishlistStore;
  final String customerId;
  final String tenantId;

  CartStoreBase({
    required CartRepository cartRepository,
    required WishlistStore wishlistStore,
    required this.customerId,
    required this.tenantId,
  }) : _cartRepository = cartRepository,
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
    loadCart();
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
  String? get appliedCouponCode => calculation?.coupon?.code;

  @computed
  int get selectedItemsCount => selectedItemIds.length;

  @computed
  List<CartItem> get checkoutItems {
    return cart.items
        .where((item) => selectedItemIds.contains(item.id))
        .toList();
  }

  @computed
  bool get isCartValid => checkoutItems.isNotEmpty;

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
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
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
        couponCode: couponCode,
      );
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
    calculation = null;
  }

  @action
  void selectAllItems() {
    selectedItemIds
      ..clear()
      ..addAll(cart.items.map((item) => item.id));
    calculation = null;
  }

  @action
  void clearSelection() {
    selectedItemIds.clear();
    calculation = null;
  }

  @action
  void updateSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  void updateFilter(String filter) {
    cartFilterBy = filter;
  }

  WishlistItem _mapCartItemToWishlistItem(CartItem item) {
    return WishlistItem(
      id: 'wishlist_${item.id}',
      wishlistId: 'wishlist_$customerId',
      productId: item.productId,
      variantId: item.variantId,
      addedAt: DateTime.now(),
      productName: item.productName,
      sku: item.sku,
      productType: item.productType,
      productStatus: item.productStatus,
      sellingPrice: item.unitPrice,
      originalPrice: item.originalPrice,
      thumbnailUrl: item.thumbnailUrl,
      variantSummary: item.variantSummary,
      attributes: item.attributes
          .map(
            (attr) =>
                WishlistItemAttribute(label: attr.label, value: attr.value),
          )
          .toList(),
      isAvailable: item.isAvailable,
    );
  }

  @action
  Future<void> moveCartItemToWishlist(CartItem item) async {
    isLoading = true;
    errorMessage = null;

    try {
      final wishlistItem = _mapCartItemToWishlistItem(item);

      if (!_wishlistStore.containsItem(item.productId, item.variantId)) {
        await _wishlistStore.addToWishlist(
          productId: wishlistItem.productId,
          variantId: wishlistItem.variantId,
        );
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
      if (!item.isAvailable) {
        throw Exception('Item is out of stock');
      }

      cart = await _cartRepository.moveWishlistItemToCart(
        customerId: customerId,
        tenantId: tenantId,
        wishlistItemId: item.id,
        quantity: 1,
      );

      await _wishlistStore.loadWishlist();
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
      for (final itemId in itemIds) {
        cart = await _cartRepository.removeCartItem(
          customerId: customerId,
          tenantId: tenantId,
          itemId: itemId,
        );
        selectedItemIds.remove(itemId);
      }
      calculation = null;
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
