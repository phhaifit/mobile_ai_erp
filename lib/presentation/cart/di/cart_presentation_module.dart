import 'package:get_it/get_it.dart';
import 'package:mobile_ai_erp/data/repository/cart/cart_repository.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/cart/store/wishlist_store.dart';

/// Dependency Injection module for Cart presentation layer.
/// Registers CartStore and WishlistStore (MobX stores)
class CartPresentationModule {
  CartPresentationModule._();

  /// Setup cart presentation layer dependencies
  static void setup(GetIt getIt, {required String userId}) {
    // Register stores
    _setupStores(getIt, userId: userId);
  }

  /// Register CartStore and WishlistStore as singletons
  static void _setupStores(GetIt getIt, {required String userId}) {
    // Get CartRepository (should already be registered in data layer)
    final cartRepository = getIt<CartRepository>();

    // Register CartStore as singleton
    getIt.registerSingleton<CartStore>(
      CartStore(
        cartRepository: cartRepository,
        userId: userId,
      ),
    );

    // Register WishlistStore as singleton
    getIt.registerSingleton<WishlistStore>(
      WishlistStore(
        cartRepository: cartRepository,
        userId: userId,
      ),
    );
  }

  /// Reset/clear presentation module from GetIt (useful for logout/testing)
  static void reset(GetIt getIt) {
    if (getIt.isRegistered<CartStore>()) {
      getIt.unregister<CartStore>();
    }

    if (getIt.isRegistered<WishlistStore>()) {
      getIt.unregister<WishlistStore>();
    }
  }

  /// Check if presentation module is registered
  static bool isRegistered(GetIt getIt) {
    return getIt.isRegistered<CartStore>() &&
        getIt.isRegistered<WishlistStore>();
  }

  /// Reinitialize stores (useful after user login)
  /// Call this when switching users or after authentication
  static void reinitialize(GetIt getIt, {required String newUserId}) {
    // Reset old stores
    reset(getIt);

    // Setup new stores with new user ID
    setup(getIt, userId: newUserId);
  }

  /// Initialize stores on app start
  /// Call this in main() or after successful authentication
  static Future<void> initializeStores(GetIt getIt) async {
    if (getIt.isRegistered<CartStore>()) {
      final cartStore = getIt<CartStore>();
      await cartStore.initialize();
    }

    if (getIt.isRegistered<WishlistStore>()) {
      final wishlistStore = getIt<WishlistStore>();
      await wishlistStore.initialize();
    }
  }

  /// Dispose stores on app exit
  /// Call this in main() cleanup or on user logout
  static void disposeStores(GetIt getIt) {
    if (getIt.isRegistered<CartStore>()) {
      getIt<CartStore>().dispose();
    }

    if (getIt.isRegistered<WishlistStore>()) {
      getIt<WishlistStore>().dispose();
    }
  }
}
