import 'package:mobile_ai_erp/data/sharedpref/constants/preferences.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/home/store/language/language_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/theme/theme_store.dart';
import 'package:mobile_ai_erp/presentation/post/post_list.dart';
import 'package:mobile_ai_erp/presentation/product_metadata/navigation/product_metadata_navigator.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildReportsEntry(),
          Expanded(child: PostListScreen()),
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

  // app bar methods:-----------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(AppLocalizations.of(context).translate('home_tv_posts')),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      _buildProductMetadataButton(),
      _buildOrderTrackingButton(),
      _buildLanguageButton(),
      _buildThemeButton(),
      _buildLogoutButton(),
    ];
  }

  Widget _buildProductMetadataButton() {
    return IconButton(
      tooltip: 'Product metadata',
      onPressed: () {
        ProductMetadataNavigator.openProductMetadataHome(context);
      },
      icon: const Icon(Icons.dashboard_outlined),
    );
  }

  Widget _buildOrderTrackingButton() {
    return IconButton(
      tooltip: 'Track Order',
      onPressed: () {
        Navigator.of(context).pushNamed(Routes.orderTracking);
      },
      icon: Icon(
        Icons.local_shipping_outlined,
      ),
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
        SharedPreferences.getInstance().then((preference) {
          preference.setBool(Preferences.is_logged_in, false);
          Navigator.of(context).pushReplacementNamed(Routes.login);
        });
      },
      icon: Icon(
        Icons.power_settings_new,
      ),
    );
  }

  Widget _buildLanguageButton() {
    return IconButton(
      onPressed: () {
        _buildLanguageDialog();
      },
      icon: Icon(
        Icons.language,
      ),
    );
  }

  _buildLanguageDialog() {
    _showDialog<String>(
      context: context,
      child: AlertDialog(
        // borderRadius: 5.0,
        // enableFullWidth: true,

        title: Text(
          AppLocalizations.of(context).translate('home_tv_choose_language'),
        ),
        // headerColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // closeButtonColor: Colors.white,
        // enableCloseButton: true,
        // enableBackButton: false,
        // onCloseButtonClicked: () {
        //   Navigator.of(context).pop();
        // },
        actions: _languageStore.supportedLanguages
            // children: _languageStore.supportedLanguages
            .map(
              (object) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.all(0.0),
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
                  // change user language based on selected locale
                  _languageStore.changeLanguage(object.locale);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  _showDialog<T>({required BuildContext context, required Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T? value) {
      // The value passed to Navigator.pop() or null.
    });
  }
}
