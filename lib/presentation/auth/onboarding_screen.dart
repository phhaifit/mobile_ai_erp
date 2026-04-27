import 'package:another_flushbar/flushbar_helper.dart';
import 'package:mobile_ai_erp/core/widgets/progress_indicator_widget.dart';
import 'package:mobile_ai_erp/core/widgets/rounded_button_widget.dart';
import 'package:mobile_ai_erp/core/widgets/textfield_widget.dart';
import 'package:mobile_ai_erp/presentation/login/store/login_store.dart';
import 'package:mobile_ai_erp/utils/device/device_utils.dart';
import 'package:mobile_ai_erp/utils/locale/app_localization.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../di/service_locator.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  //text controllers:-----------------------------------------------------------
  TextEditingController _tenantNameController = TextEditingController();
  TextEditingController _subdomainController = TextEditingController();

  //stores:---------------------------------------------------------------------
  final LoginStore _userStore = getIt<LoginStore>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: AppBar(
        title: Text('Create Your Workspace'),
      ),
      body: _buildBody(),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        _buildContent(),
        Observer(
          builder: (context) {
            return _userStore.isLoggedIn && !_userStore.needsOnboarding
                ? _navigateToHome(context)
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

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to AI ERP!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Text(
              'Create your workspace to get started. This will be your company\'s dedicated environment.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.0),
            _buildTenantNameField(),
            _buildSubdomainField(),
            SizedBox(height: 24.0),
            _buildCreateButton(),
            SizedBox(height: 16.0),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantNameField() {
    return TextFieldWidget(
      hint: 'Workspace Name (e.g., My Company)',
      inputType: TextInputType.text,
      icon: Icons.business,
      textController: _tenantNameController,
      inputAction: TextInputAction.next,
      errorText: 'Error _buildTenantNameField',
      onChanged: (value) {},
      onFieldSubmitted: (value) {
        FocusScope.of(context).nextFocus();
      },
    );
  }

  Widget _buildSubdomainField() {
    return TextFieldWidget(
      hint: 'Subdomain (e.g., mycompany)',
      inputType: TextInputType.text,
      icon: Icons.link,
      textController: _subdomainController,
      inputAction: TextInputAction.done,
      errorText: 'Error _buildSubdomainField',
      onChanged: (value) {},
      onFieldSubmitted: (value) {
        _createTenant();
      },
    );
  }

  Widget _buildCreateButton() {
    return RoundedButtonWidget(
      buttonText: 'Create Workspace',
      buttonColor: Colors.blueAccent,
      textColor: Colors.white,
      onPressed: () async {
        if (_validateInputs()) {
          DeviceUtils.hideKeyboard(context);
          await _createTenant();
        }
      },
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () async {
        await _userStore.logout();
        Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.login, (Route<dynamic> route) => false);
      },
      child: Text(
        'Cancel',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  bool _validateInputs() {
    final name = _tenantNameController.text.trim();
    final subdomain = _subdomainController.text.trim();

    if (name.isEmpty) {
      _showErrorMessage('Please enter a workspace name');
      return false;
    }

    if (subdomain.isEmpty) {
      _showErrorMessage('Please enter a subdomain');
      return false;
    }

    // Basic subdomain validation (alphanumeric + hyphens, 3-63 chars)
    final subdomainRegex = RegExp(r'^[a-z0-9][a-z0-9\-]{1,61}[a-z0-9]$');
    if (!subdomainRegex.hasMatch(subdomain)) {
      _showErrorMessage('Subdomain must be 3-63 characters, contain only lowercase letters, numbers, and hyphens');
      return false;
    }

    return true;
  }

  Future<void> _createTenant() async {
    try {
      await _userStore.createTenant(
        _tenantNameController.text.trim(),
        _subdomainController.text.trim(),
      );
    } catch (e) {
      _showErrorMessage('Failed to create workspace: ${e.toString()}');
    }
  }

  Widget _navigateToHome(BuildContext context) {
    Future.delayed(Duration(milliseconds: 0), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.home, (Route<dynamic> route) => false);
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
            title: AppLocalizations.of(context).translate('Error'),
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
    _tenantNameController.dispose();
    _subdomainController.dispose();
    super.dispose();
  }
}