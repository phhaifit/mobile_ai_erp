import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/customer/screens/register/widgets/email_verification_dialog.dart';
import 'package:mobile_ai_erp/presentation/customer/store/auth_store.dart';
import 'package:mobile_ai_erp/presentation/customer/store/signin_store.dart';
import 'package:mobile_ai_erp/presentation/customer/widgets/auth_error_dialog.dart';
import 'widgets/email_password_tab.dart';
import 'widgets/magic_link_tab.dart';
import 'package:mobile_ai_erp/presentation/customer/screens/login/widgets/oauth_buttons.dart';
import 'package:mobile_ai_erp/utils/routes/routes.dart';

/// Main login screen with tabbed interface for different auth methods
class CustomerLoginScreen extends StatefulWidget {
  final Function(String)? onMagicLinkRequest;
  final VoidCallback? onForgotPasswordPressed;
  final VoidCallback? onSignUpPressed;

  const CustomerLoginScreen({
    super.key,
    this.onMagicLinkRequest,
    this.onForgotPasswordPressed,
    this.onSignUpPressed,
  }) : super();

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late SignInStore _signInStore;
  late CustomerAuthStore _authStore;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _signInStore = getIt<SignInStore>();
    _authStore = getIt<CustomerAuthStore>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _checkAndShowError(String title) {
    if (mounted && _signInStore.errorMessage?.isEmpty == false) {
      AuthErrorDialog.show(
        context,
        message: _signInStore.errorMessage!,
        title: title,
      );
      _signInStore.errorMessage = null;
    }
  }

  void _handleEmailPasswordSignIn(String email, String password) async {
    await _signInStore.signIn(
      email: email,
      password: password,
    );
    _checkAndShowError('Sign In Failed');
  }

  void _handleGoogleOAuthPressed() async {
    await _signInStore.signInWithGoogle();
  }

  void _handleRequestMagicLink(String email) async {
    final result = await _signInStore.requestMagicLink(email: email);
    if (result) {
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => EmailVerificationDialog(
            email: _signInStore.magicLinkEmail,
            signInStore: _signInStore,
          ),
        );
      }
    } else {
      _checkAndShowError('Sign In Failed');
    }
    _signInStore.resetMagicLink();
  }

  void _handleSignUpPressed() {
    Navigator.of(context).pushNamed(Routes.customerRegister);
  }

  Widget navigateToHome(BuildContext context) {
    Future.delayed(Duration(milliseconds: 0), () {
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.customerHome, (Route<dynamic> route) => false);
      }
    });

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return _authStore.isLoggedIn
            ? navigateToHome(context)
            : _build(context);
      },
    );
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: ModalRoute.of(context)?.canPop ?? false
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Theme.of(context).primaryColor,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  text: 'Email & Password',
                  icon: Icon(Icons.mail_outline, size: 20),
                ),
                Tab(
                  text: 'Magic Code',
                  icon: Icon(Icons.link, size: 20),
                ),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Email/Password Tab
                EmailPasswordTab(
                  signInStore: _signInStore,
                  onSubmit: _handleEmailPasswordSignIn,
                  onForgotPassword: widget.onForgotPasswordPressed,
                  onSignUp: _handleSignUpPressed,
                ),

                // Magic Code Tab
                MagicLinkTab(
                  signInStore: _signInStore,
                  onMagicLinkRequest: _handleRequestMagicLink,
                ),
              ],
            ),
          ),

          // OAuth buttons and footer
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Divider with text
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 16),

                // Google OAuth button
                GoogleOAuthButton(
                  isLoading: _signInStore.isGoogleOAuthLoading,
                  onPressed: _handleGoogleOAuthPressed,
                ),
                const SizedBox(height: 12),

                // Terms
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: RichText(
                      text: TextSpan(
                        text: 'By signing in, you agree to our ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
