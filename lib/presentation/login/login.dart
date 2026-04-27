import 'package:another_flushbar/flushbar_helper.dart';
import 'package:mobile_ai_erp/constants/assets.dart';
import 'package:mobile_ai_erp/core/widgets/app_icon_widget.dart';
import 'package:mobile_ai_erp/core/widgets/empty_app_bar_widget.dart';
import 'package:mobile_ai_erp/core/widgets/progress_indicator_widget.dart';
import 'package:mobile_ai_erp/core/widgets/rounded_button_widget.dart';
import 'package:mobile_ai_erp/presentation/login/store/login_store.dart';
import 'package:mobile_ai_erp/utils/device/device_utils.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //stores:---------------------------------------------------------------------
  final LoginStore _loginStore = getIt<LoginStore>();

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
            return _loginStore.isLoggedIn && !_loginStore.needsOnboarding
                ? navigateToHome(context)
                : _loginStore.needsOnboarding
                    ? navigateToOnboarding(context)
                    : _showErrorMessage(_loginStore.errorMessage ?? '');
          },
        ),
        Observer(
          builder: (context) {
            return Visibility(
              visible: _loginStore.isLoading,
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
          _loginStore.isLoading = true;
          await _loginStore.authenticate();
        } catch (e) {
          debugPrint(e.toString());
          _showErrorMessage("Failed to authenticate");
        } finally {
          _loginStore.isLoading = false;
        }
      },
    );
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
