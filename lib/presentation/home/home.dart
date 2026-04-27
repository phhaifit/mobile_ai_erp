import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/core/stores/supplier/supplier_store.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/customer_management/navigation/customer_navigator.dart';
import 'package:mobile_ai_erp/presentation/home/store/language/language_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/theme/theme_store.dart';
import 'package:mobile_ai_erp/presentation/login/store/login_store.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/presentation/supplier/supplier_list/supplier_list_screen.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/mini_cart_drawer.dart';
import 'package:mobile_ai_erp/presentation/cart/store/wishlist_store.dart';
import 'package:mobile_ai_erp/presentation/cart/screens/wishlist_page.dart';
import 'package:mobile_ai_erp/utils/routes/cart_routes.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:mobile_ai_erp/constants/strings.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  final LoginStore _loginStore = getIt<LoginStore>();
  late final CartStore _cartStore;
  late final WishlistStore _wishlistStore;

  @override
  void initState() {
    super.initState();
    _cartStore = getIt<CartStore>();
    _wishlistStore = getIt<WishlistStore>();

    _cartStore.loadCart();
    _wishlistStore.loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          _buildDashboardEntry(),
          _buildStorefrontPDPEntry(),
          _buildReportsEntry(),
          _buildPostPurchaseEntry(),
          _buildStorefrontEntry(),
          _buildCustomerPortalEntry(),
          _buildSuppliersEntry(),
          _buildUsersManagementEntry(),
          _buildProductsBody(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.webBuilder);
        },
        icon: const Icon(Icons.web),
        label: const Text('Web Builder'),
      ),
    );
  }

  Widget _buildCartButton() {
    return Observer(
      builder: (context) {
        return MiniCartBadge(
          itemCount: _cartStore.itemCount,
          onTap: () {
            CartRoutes.navigateToCart(context);
          },
          hasDiscount: _cartStore.hasCoupon,
        );
      },
    );
  }

  Widget _buildWishlistButton() {
    return Observer(
      builder: (context) {
        final count = _wishlistStore.itemCount;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Wishlist',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistPage()),
                );
              },
              icon: const Icon(Icons.favorite_border),
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStorefrontPDPEntry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.storefront_outlined),
          title: Text('Product Detail Page'),
          subtitle: Text(
            'Storefront PDP - View sample product (offline mock).',
          ),
          trailing: Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(Routes.productDetail),
        ),
      ),
    );
  }

  Widget _buildDashboardEntry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.dashboard_customize_outlined),
          title: const Text('Dashboard'),
          subtitle: const Text(
            'Business health, tasks, sales trend, and insights (offline mock).',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(Routes.dashboard),
        ),
      ),
    );
  }

  Widget _buildReportsEntry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.insights_outlined),
          title: Text('Reports & Analytics'),
          subtitle: Text('Sales, inventory, product, and P&L (offline mock).'),
          trailing: Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(Routes.reports),
        ),
      ),
    );
  }

  Widget _buildPostPurchaseEntry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.support_agent_outlined),
          title: Text('Post-Purchase & Issues'),
          subtitle: Text('Complaints, returns, and exchanges (offline mock).'),
          trailing: Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(Routes.postPurchase),
        ),
      ),
    );
  }

  Widget _buildStorefrontEntry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.shopping_cart),
          title: Text('Storefront'),
          subtitle: Text('View all available products.'),
          trailing: Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(Routes.storeHome),
        ),
      ),
    );
  }

  Widget _buildUsersManagementEntry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.insights_outlined),
          title: Text('User Management'),
          subtitle: Text('User & Roles Managements (offline mock).'),
          trailing: Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(Routes.users),
        ),
      ),
    );
  }

  Widget _buildSuppliersEntry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.store),
          title: Text("Suppliers"),
          trailing: Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SupplierListScreen(store: getIt<SupplierStore>()),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomerPortalEntry() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        child: ListTile(
          leading: Icon(
            Icons.person_outline,
          ), // Icon representing a user profile
          title: Text('Customer Portal (Storefront)'),
          subtitle: Text('Manage profile, address book, and order history.'),
          trailing: Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).pushNamed(Routes.profileDashboard),
        ),
      ),
    );
  }

  Widget _buildProductsBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        child: ListTile(
          leading: Icon(Icons.insights_outlined),
          title: Text(ProductStrings.screenTitle),
          subtitle: Text(ProductStrings.screenDescription),
          trailing: Icon(Icons.chevron_right),
          onTap: () =>
              Navigator.of(context).pushNamed(Routes.productManagementList),
        ),
      ),
    );
  }

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).translate('home_tv_posts')),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width <= 390;
    if (isCompact) {
      return <Widget>[
        _buildCartButton(),
        _buildWishlistButton(),
        _buildOverflowMenu(compact: true),
      ];
    }

    return <Widget>[
      _buildInventoryAuditButton(),
      _buildCartButton(),
      _buildWishlistButton(),
      _buildOrderTrackingButton(),
      _buildFulfillmentButton(),
      _buildPostPurchaseButton(),
      _buildLanguageButton(),
      _buildThemeButton(),
      _buildLogoutButton(),
      _buildOverflowMenu(compact: false),
    ];
  }

  Widget _buildOverflowMenu({required bool compact}) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'More options',
      onSelected: (value) => _handleMenuSelection(value),
      itemBuilder: (context) => [
        if (compact)
          const PopupMenuItem(
            value: 'inventoryAudit',
            child: ListTile(
              leading: Icon(Icons.fact_check_outlined),
              title: Text('Inventory Audit'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (compact)
          const PopupMenuItem(
            value: 'orderTracking',
            child: ListTile(
              leading: Icon(Icons.local_shipping_outlined),
              title: Text('Order Tracking'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (compact)
          const PopupMenuItem(
            value: 'fulfillment',
            child: ListTile(
              leading: Icon(Icons.inventory_2_outlined),
              title: Text('Order Fulfillment'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (compact)
          const PopupMenuItem(
            value: 'postPurchase',
            child: ListTile(
              leading: Icon(Icons.support_agent_outlined),
              title: Text('Post-Purchase & Issues'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (compact)
          const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'dashboard',
          child: ListTile(
            leading: Icon(Icons.dashboard_customize_outlined),
            title: Text('Dashboard'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'stock',
          child: ListTile(
            leading: Icon(Icons.warehouse_outlined),
            title: Text('Stock Operations'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'customer',
          child: ListTile(
            leading: Icon(Icons.people_outline),
            title: Text('Customer Management'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'productMetadata',
          child: ListTile(
            leading: Icon(Icons.dashboard_outlined),
            title: Text('Product Metadata'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'language',
          child: ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'theme',
          child: Observer(
            builder: (context) => ListTile(
              leading: Icon(
                _themeStore.darkMode ? Icons.brightness_5 : Icons.brightness_3,
              ),
              title: Text(_themeStore.darkMode ? 'Light Mode' : 'Dark Mode'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.power_settings_new),
            title: Text('Logout'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'inventoryAudit':
        Navigator.of(context).pushNamed(Routes.inventoryAudit);
        break;
      case 'orderTracking':
        Navigator.of(context).pushNamed(Routes.orderTracking);
        break;
      case 'fulfillment':
        Navigator.of(context).pushNamed(Routes.fulfillment);
        break;
      case 'postPurchase':
        Navigator.of(context).pushNamed(Routes.postPurchase);
        break;
      case 'dashboard':
        Navigator.of(context).pushNamed(Routes.dashboard);
        break;
      case 'stock':
        Navigator.of(context).pushNamed(Routes.stockOperations);
        break;
      case 'customer':
        CustomerNavigator.openHome(context);
        break;
      case 'productMetadata':
        ProductMetadataNavigator.openProductMetadataHome(context);
        break;
      case 'language':
        _buildLanguageDialog();
        break;
      case 'theme':
        _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
        break;
      case 'logout':
        _loginStore.logout().then((_) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(Routes.login);
          }
        });
        break;
    }
  }

  Widget _buildInventoryAuditButton() {
    return IconButton(
      tooltip: 'Inventory Audit',
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.inventoryAudit);
      },
      icon: const Icon(Icons.fact_check_outlined),
    );
  }

  Widget _buildFulfillmentButton() {
    return IconButton(
      tooltip: 'Order Fulfillment',
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.fulfillment);
      },
      icon: const Icon(Icons.inventory_2_outlined),
    );
  }

  Widget _buildPostPurchaseButton() {
    return IconButton(
      tooltip: 'Post-Purchase & Issues',
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.postPurchase);
      },
      icon: const Icon(Icons.support_agent_outlined),
    );
  }

  Widget _buildOrderTrackingButton() {
    return IconButton(
      tooltip: 'Track Order',
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.orderTracking);
      },
      icon: Icon(Icons.local_shipping_outlined),
    );
  }

  Widget _buildThemeButton() {
    return Observer(
      builder: (context) {
        return IconButton(
          onPressed: () {
            _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
          },
          icon: Icon(
            _themeStore.darkMode ? Icons.brightness_5 : Icons.brightness_3,
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
      onPressed: () {
        _loginStore.logout().then((_) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(Routes.login);
          }
        });
      },
      icon: const Icon(Icons.power_settings_new),
    );
  }

  Widget _buildLanguageButton() {
    return IconButton(
      onPressed: _buildLanguageDialog,
      icon: const Icon(Icons.language),
    );
  }

  void _buildLanguageDialog() {
    _showDialog<String>(
      context: context,
      child: AlertDialog(
        title: Text(
          AppLocalizations.of(context).translate('home_tv_choose_language'),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: _languageStore.supportedLanguages
            .map(
              (object) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.all(0.0),
                title: Text(
                  object.language,
                  style: TextStyle(
                    color: _languageStore.locale == object.locale
                        ? Theme.of(context).primaryColor
                        : _themeStore.darkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _languageStore.changeLanguage(object.locale);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  void _showDialog<T>({required BuildContext context, required Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T? value) {});
  }
}
