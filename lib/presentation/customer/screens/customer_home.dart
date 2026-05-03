import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/presentation/cart/store/cart_store.dart';
import 'package:mobile_ai_erp/presentation/cart/store/wishlist_store.dart';
import 'package:mobile_ai_erp/presentation/cart/widgets/mini_cart_drawer.dart';
import 'package:mobile_ai_erp/presentation/cart/screens/wishlist_page.dart';
import 'package:mobile_ai_erp/presentation/customer/store/auth_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/language/language_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/theme/theme_store.dart';
import 'package:mobile_ai_erp/presentation/storefront/storefront_home_page.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';
import 'package:mobile_ai_erp/utils/routes/cart_routes.dart';
import 'package:mobile_ai_erp/utils/routes/customer_routes.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';

/// Customer home page with cart, wishlist, theme, and language features
class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  final CustomerAuthStore _authStore = getIt<CustomerAuthStore>();
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
      body: StorefrontHomePage(),
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
      _buildCartButton(),
      _buildWishlistButton(),
      _buildLanguageButton(),
      _buildThemeButton(),
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
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            contentPadding: EdgeInsets.zero,
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
      case 'language':
        _buildLanguageDialog();
        break;
      case 'theme':
        _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
        break;
      case 'profile':
        Navigator.pushNamed(context, CustomerRoutes.profileDashboard);
        break;
      case 'logout':
        _authStore.logout().then((_) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/');
          }
        });
        break;
    }
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
