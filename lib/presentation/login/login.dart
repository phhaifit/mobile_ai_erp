import 'dart:math';

import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_ai_erp/constants/assets.dart';
import 'package:mobile_ai_erp/core/data/network/constants/network_constants.dart';
import 'package:mobile_ai_erp/core/stores/form/form_store.dart';
import 'package:mobile_ai_erp/core/widgets/app_icon_widget.dart';
import 'package:mobile_ai_erp/core/widgets/empty_app_bar_widget.dart';
import 'package:mobile_ai_erp/core/widgets/progress_indicator_widget.dart';
import 'package:mobile_ai_erp/core/widgets/rounded_button_widget.dart';
import 'package:mobile_ai_erp/core/widgets/textfield_widget.dart';
import 'package:mobile_ai_erp/data/network/constants/endpoints.dart';
import 'package:mobile_ai_erp/data/sharedpref/constants/preferences.dart';
import 'package:mobile_ai_erp/data/sharedpref/shared_preference_helper.dart';
import 'package:mobile_ai_erp/domain/repository/user/auth_repository.dart';
import 'package:mobile_ai_erp/presentation/home/store/theme/theme_store.dart';
import 'package:mobile_ai_erp/presentation/login/store/login_store.dart';
import 'package:mobile_ai_erp/utils/device/device_utils.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mobile_ai_erp/presentation/auth/onboarding_screen.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //stores:---------------------------------------------------------------------
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final UserStore _userStore = getIt<UserStore>();
  final AuthRepository _authRepository = getIt<AuthRepository>();
  final SharedPreferenceHelper _sharedPreferenceHelper = getIt<SharedPreferenceHelper>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: EmptyAppBar(),
      body: _buildBody(),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        MediaQuery.of(context).orientation == Orientation.landscape
            ? Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: _buildLeftSide(),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildRightSide(),
                  ),
                ],
              )
            : Center(child: _buildRightSide()),
        Observer(
          builder: (context) {
            return _userStore.isAuthenticated && !_userStore.needsOnboarding
                ? navigateToHome(context)
                : _userStore.needsOnboarding
                    ? navigateToOnboarding(context)
                    : _showErrorMessage(_userStore.errorMessage ?? '');
          },
        ),
        Observer(
          builder: (context) {
            return Visibility(
              visible: _userStore.isLoading,
              child: CustomProgressIndicatorWidget(),
            );
          },
        )
      ],
    );
  }

  Widget _buildLeftSide() {
    return SizedBox.expand(
      child: Image.asset(
        Assets.carBackground,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppIconWidget(image: 'assets/icons/ic_appicon.png'),
            SizedBox(height: 24.0),
            _buildSignInWithStackAuthButton()
          ],
        ),
      ),
    );
  }

  Widget _buildSignInWithStackAuthButton() {
    return RoundedButtonWidget(
      buttonText: 'Sign In with Stack Auth',
      buttonColor: Colors.blueAccent,
      textColor: Colors.white,
      onPressed: () async {
        DeviceUtils.hideKeyboard(context);
        try {
          await _authenticate();
        } catch (e) {
          debugPrint(e.toString());
          _showErrorMessage("Failed to authenticate");
        }
      },
    );
  }

  (String, String) _getRedirectUri() {
    if (defaultTargetPlatform == TargetPlatform.windows ||
       defaultTargetPlatform == TargetPlatform.linux ||
       defaultTargetPlatform == TargetPlatform.macOS) {
        // TODO: dynamic port
        return ('http://localhost:13123', 'http://localhost:13123/');
    }
    throw UnimplementedError();
  }

  (String, String) _generateCodeChallenge() {
    const codeChallenge = "xf6HY7PIgoaCf_eMniSt-45brYE2J_05C9BnfIbueik";
    const codeVerifier = "W2LPAD4M4ES-3wBjzU6J5ApykmuxQy5VTs3oSmtboDM";
    return (codeChallenge, codeVerifier);
  }

  String _randomState(int len) {
    var r = Random();
    return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
  }

  Future<void> _authenticate() async {
    final (callbackUrlScheme, redirectUri) = _getRedirectUri();
    final (codeChallenge, codeVerifier) = _generateCodeChallenge();
    const authProviderId = "google";
    final state = _randomState(32);
    final stackAuthUrl = Uri.https(Endpoints.stackAuthHost, "${Endpoints.stackAuthAuthenticate}/$authProviderId", {
      'client_id': NetworkConstants.stackAuthClientId,
      'client_secret': NetworkConstants.stackAuthClientSecret,
      'redirect_uri': redirectUri,
      'scope': 'legacy',
      'grant_type': 'authorization_code',
      'response_type': 'code',
      'code_challenge_method': "S256",
      'code_challenge': codeChallenge,

      'state': state,
    });
    final resultUriStr = await FlutterWebAuth2.authenticate(url: stackAuthUrl.toString(), callbackUrlScheme: callbackUrlScheme, options: const FlutterWebAuth2Options(useWebview: false));
    final resultUri = Uri.parse(resultUriStr);

    if (state != (resultUri.queryParameters['code'] ?? '')) {
      throw ErrorSummary('invalid state received back');
    }
    final authorizationCode = resultUri.queryParameters['code'] ?? '';
    final tokens = await _authRepository.getAccessToken(authorizationCode, codeVerifier);
    debugPrint("Access token: ${tokens.accessToken}");
    debugPrint("Refresh token: ${tokens.refreshToken}");

    final user = await _authRepository.getAuthStatus(tokens.accessToken);
    debugPrint(user.toString());

    await _sharedPreferenceHelper.saveAuthToken(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
  }

  Widget navigateToHome(BuildContext context) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false);
      }
    });

    return Container();
  }

  Widget navigateToOnboarding(BuildContext context) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.onboarding, (Route<dynamic> route) => false);
      }
    });

    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: AppLocalizations.of(context).translate('home_tv_error'),
            duration: Duration(seconds: 3),
          )..show(context);
        }
      });
    }

    return SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    super.dispose();
  }
}
