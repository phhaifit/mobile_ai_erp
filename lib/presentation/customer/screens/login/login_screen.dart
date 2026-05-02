import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/customer/store/signin_store.dart';
import 'widgets/email_password_tab.dart';
import 'widgets/magic_link_tab.dart';
import 'package:mobile_ai_erp/presentation/customer/screens/login/widgets/oauth_buttons.dart';
import '../register/register_screen.dart';

/// Main login screen with tabbed interface for different auth methods
class CustomerLoginScreen extends StatefulWidget {
  final Function(String)? onMagicLinkRequest;
  final Function()? onGoogleOAuthPressed;
  final VoidCallback? onForgotPasswordPressed;
  final VoidCallback? onSignUpPressed;

  const CustomerLoginScreen({
    super.key,
    this.onMagicLinkRequest,
    this.onGoogleOAuthPressed,
    this.onForgotPasswordPressed,
    this.onSignUpPressed,
  }) : super();

  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late SignInStore _signInStore;
  bool _isMagicLinkLoading = false;
  bool _isGoogleOAuthLoading = false;
  String? _magicLinkError;
  bool _isMagicLinkSent = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _signInStore = getIt<SignInStore>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleEmailPasswordSignIn(Map<String, String> credentials) async {
    await _signInStore.signIn(
      email: credentials['email'] ?? '',
      password: credentials['password'] ?? '',
    );
  }

  void _handleMagicLinkRequest(String email) {
    setState(() {
      _isMagicLinkLoading = true;
      _magicLinkError = null;
    });

    // TODO: Implement magic link sign in
    // For now, simulate API call - in real app, this would call the use case
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isMagicLinkLoading = false;
          _isMagicLinkSent = true;
        });
        // Call parent handler
        widget.onMagicLinkRequest?.call(email);
      }
    });
  }

  void _handleGoogleOAuthPressed() {
    setState(() => _isGoogleOAuthLoading = true);

    // TODO: Implement Google OAuth
    // Simulate Google OAuth flow
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isGoogleOAuthLoading = false);
        widget.onGoogleOAuthPressed?.call();
      }
    });
  }

  void _handleSignUpPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to access your AI ERP account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
                  text: 'Magic Link',
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
                // Email/Password Tab - wrapped with Observer to listen to store state
                Observer(
                  builder: (_) => EmailPasswordTab(
                    isLoading: _signInStore.isLoading,
                    errorMessage: _signInStore.errorMessage,
                    onSubmit: _handleEmailPasswordSignIn,
                    onForgotPassword: widget.onForgotPasswordPressed,
                    onSignUp: _handleSignUpPressed,
                  ),
                ),

                // Magic Link Tab
                MagicLinkTab(
                  isLoading: _isMagicLinkLoading,
                  errorMessage: _magicLinkError,
                  isLinkSent: _isMagicLinkSent,
                  onSubmit: _handleMagicLinkRequest,
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
                  isLoading: _isGoogleOAuthLoading,
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
