import 'package:mobx/mobx.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist.dart';
import 'package:mobile_ai_erp/domain/entity/cart/wishlist_item.dart';

part 'wishlist_store.g.dart';

class WishlistStore = WishlistStoreBase with _$WishlistStore;

abstract class WishlistStoreBase with Store {
  final CartRepository _cartRepository;

  WishlistStoreBase({required CartRepository cartRepository})
    : _cartRepository = cartRepository {
    wishlist = Wishlist(
      id: '',
      tenantId: '',
      customerId: '',
      totalItems: 0,
      items: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @observable
  late Wishlist wishlist;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String sortBy = 'recent';

  @observable
  String searchQuery = '';

  @observable
  ObservableList<String> selectedItemIds = ObservableList<String>();

  @observable
  Map<String, dynamic>? wishlistSummary;

  @computed
  List<WishlistItem> get items => wishlist.items;

  @computed
  int get itemCount => wishlist.totalItems;

  @computed
  int get wishlistBadgeCount =>
      (wishlistSummary?['totalItems'] as num?)?.toInt() ?? wishlist.totalItems;

  @computed
  bool get isEmpty => wishlist.items.isEmpty;

  @computed
  List<WishlistItem> get availableItems =>
      wishlist.items.where((item) => item.isAvailable).toList();

  @computed
  List<WishlistItem> get unavailableItems =>
      wishlist.items.where((item) => !item.isAvailable).toList();

  @computed
  List<WishlistItem> get filteredAndSortedItems {
    var filtered = wishlist.items.toList();

    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((item) {
        final productName = item.productName.toLowerCase();
        final sku = item.sku.toLowerCase();
        final variantSummary = (item.variantSummary ?? '').toLowerCase();
        final attributesText = item.attributes
            .map((attr) => '${attr.label} ${attr.value}'.toLowerCase())
            .join(' ');

        return productName.contains(query) ||
            sku.contains(query) ||
            variantSummary.contains(query) ||
            attributesText.contains(query);
      }).toList();
    }

    final sorted = List<WishlistItem>.from(filtered);

    switch (sortBy) {
      case 'price-low':
        sorted.sort(
          (a, b) =>
              int.parse(a.sellingPrice).compareTo(int.parse(b.sellingPrice)),
        );
        break;
      case 'price-high':
        sorted.sort(
          (a, b) =>
              int.parse(b.sellingPrice).compareTo(int.parse(a.sellingPrice)),
        );
        break;
      case 'name':
        sorted.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case 'recent':
      default:
        sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
    }

    return sorted;
  }

  @computed
  int get selectedItemsCount => selectedItemIds.length;

  @computed
  List<WishlistItem> get selectedItems => wishlist.items
      .where((item) => selectedItemIds.contains(item.id))
      .toList();

  WishlistItem? getItemById(String itemId) {
    try {
      return wishlist.items.firstWhere((item) => item.id == itemId);
    } catch (_) {
      return null;
    }
  }

  bool containsItem(String productId) {
    return wishlist.items.any((item) => item.productId == productId);
  }

  void _pruneInvalidSelections() {
    final validIds = wishlist.items.map((item) => item.id).toSet();
    selectedItemIds.removeWhere((id) => !validIds.contains(id));
  }

  @action
  Future<void> loadWishlist() async {
    isLoading = true;
    errorMessage = null;

    try {
      wishlist = await _cartRepository.getWishlist();
      _pruneInvalidSelections();
      await loadWishlistSummary();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> loadWishlistSummary() async {
    try {
      wishlistSummary = await _cartRepository.getWishlistSummary();
    } catch (_) {}
  }

  @action
  Future<void> addToWishlist({required String productId}) async {
    isLoading = true;
    errorMessage = null;

    try {
      if (containsItem(productId)) {
        return;
      }

      wishlist = await _cartRepository.addToWishlist(productId: productId);
      _pruneInvalidSelections();
      await loadWishlistSummary();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> removeFromWishlist(WishlistItem item) async {
    isLoading = true;
    errorMessage = null;

    try {
      await _cartRepository.removeFromWishlist(itemId: item.id);
      selectedItemIds.remove(item.id);
      await loadWishlist();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> removeMultipleFromWishlist(
    List<WishlistItem> itemsToRemove,
  ) async {
    if (itemsToRemove.isEmpty) return;

    isLoading = true;
    errorMessage = null;

    try {
      for (final item in itemsToRemove) {
        await _cartRepository.removeFromWishlist(itemId: item.id);
      }

      selectedItemIds.clear();
      await loadWishlist();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> removeSelectedItems() async {
    if (selectedItemIds.isEmpty) return;
    await removeMultipleFromWishlist(List<WishlistItem>.from(selectedItems));
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
    selectedItemIds = ObservableList<String>.of(
      wishlist.items.map((item) => item.id),
    );
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
  void updateSortBy(String sortOption) {
    sortBy = sortOption;
  }

  @action
  void clearError() {
    errorMessage = null;
  }

  @action
  Future<void> initialize() async {
    await loadWishlist();
  }

  @action
  void dispose() {
    clearSelection();
    clearError();
  }
}
