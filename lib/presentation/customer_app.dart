import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/constants/app_theme.dart';
import 'package:mobile_ai_erp/constants/strings.dart';
import 'package:mobile_ai_erp/presentation/customer/screens/login/login_screen.dart';
import 'package:mobile_ai_erp/presentation/customer/screens/subdomain_screen.dart';
import 'package:mobile_ai_erp/presentation/customer/store/auth_store.dart';
import 'package:mobile_ai_erp/presentation/customer/store/subdomain_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/language/language_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/theme/theme_store.dart';
import 'package:mobile_ai_erp/presentation/customer/screens/customer_home.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';
import 'package:mobile_ai_erp/utils/routes/customer_routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';

/// Customer-facing app with authentication flows
class CustomerApp extends StatefulWidget {
  const CustomerApp({super.key});

  @override
  State<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends State<CustomerApp> {
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  final _subdomainStore = getIt<SubdomainStore>();
  final _authStore = getIt<CustomerAuthStore>();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkSubdomain();
  }

  Future<void> _checkSubdomain() async {
    // Validate the stored subdomain via the store
    final valid = await _subdomainStore.validateStoredSubdomain();
    if (!valid) {
      await _authStore.logout();
    }
    
    if (!mounted) return;
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Observer(
      builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Strings.appName,
          theme: _themeStore.darkMode
              ? AppThemeData.darkThemeData
              : AppThemeData.lightThemeData,
          home: _buildHome(),
          routes: CustomerRoutes.routes,
          onGenerateRoute: CustomerRoutes.onGenerateRoute,
          locale: Locale(_languageStore.locale),
          supportedLocales: _languageStore.supportedLanguages
              .map((language) => Locale(language.locale, language.code))
              .toList(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }

  Widget _buildHome() {
    if (_subdomainStore.subdomain == null) {
      return SubdomainScreen();
    }
    if (_authStore.tokenPair == null) {
      return const CustomerLoginScreen();
    }
    return const CustomerHomePage();
  }
}
