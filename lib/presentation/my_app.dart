import 'package:mobile_ai_erp/constants/app_theme.dart';
import 'package:mobile_ai_erp/constants/strings.dart';
import 'package:mobile_ai_erp/presentation/home/home.dart';
import 'package:mobile_ai_erp/presentation/home/store/language/language_store.dart';
import 'package:mobile_ai_erp/presentation/home/store/theme/theme_store.dart';
import 'package:mobile_ai_erp/presentation/login/store/login_store.dart';
import 'package:mobile_ai_erp/presentation/login/login.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../di/service_locator.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  
  bool _initialized = false;
  bool _hasSession = false;

  @override
  void initState() {
    super.initState();
    _validateStoredSession();
  }

  Future<void> _validateStoredSession() async {
    final loginStore = getIt<LoginStore>();
    final validSession = await loginStore.validateStoredSession();
    if (!mounted) return;
    setState(() {
      _initialized = true;
      _hasSession = validSession;
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
          onGenerateRoute: (settings) {
            final String routeName = settings.name ?? '/';

            // Check if the route is public
            bool isPublic = routeName == '/' ||
                routeName == Routes.login ||
                routeName == Routes.onboarding ||
                routeName.startsWith('/storefront');

            // If the route is protected and there is no session, force login
            if (!isPublic && !_hasSession) {
              return MaterialPageRoute(
                builder: (context) => LoginScreen(),
                settings: settings,
              );
            }

            // Resolve static routes
            WidgetBuilder? builder;
            if (routeName == '/') {
              builder = (context) => _hasSession ? HomeScreen() : LoginScreen();
            } else {
              builder = Routes.routes[routeName];
            }

            if (builder != null) {
              return MaterialPageRoute(
                builder: builder,
                settings: settings,
              );
            }

            // Resolve dynamic routes
            return Routes.onGenerateRoute(settings);
          },
          locale: Locale(_languageStore.locale),
          supportedLocales: _languageStore.supportedLanguages
              .map((language) => Locale(language.locale, language.code))
              .toList(),
          localizationsDelegates: const [
            // A class which loads the translations from JSON files
            AppLocalizations.delegate,
            // Built-in localization of basic text for Material widgets
            GlobalMaterialLocalizations.delegate,
            // Built-in localization for text direction LTR/RTL
            GlobalWidgetsLocalizations.delegate,
            // Built-in localization of basic text for Cupertino widgets
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
