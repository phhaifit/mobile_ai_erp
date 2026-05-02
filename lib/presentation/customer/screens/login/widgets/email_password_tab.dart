import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/utils/validators_utils.dart';
import '../../../widgets/password_field.dart';
import '../../../widgets/auth_error_dialog.dart';

/// Email/Password login tab widget
class EmailPasswordTab extends StatefulWidget {
  final Function(Map<String, String>)? onSubmit;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;

  const EmailPasswordTab({
    Key? key,
    this.onSubmit,
    this.isLoading = false,
    this.errorMessage,
    this.onForgotPassword,
    this.onSignUp,
  }) : super(key: key);

  @override
  State<EmailPasswordTab> createState() => _EmailPasswordTabState();
}

class _EmailPasswordTabState extends State<EmailPasswordTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _rememberMe;

  @override
  void initState() {
    super.initState();
    _rememberMe = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(EmailPasswordTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AuthErrorDialog.show(
            context,
            message: widget.errorMessage!,
            title: 'Sign In Failed',
          );
        }
      });
    }
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit?.call({
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'rememberMe': _rememberMe.toString(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: widget.isLoading,
      message: 'Signing in...',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome message
              Text(
                'Sign in to your account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email and password to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: ValidatorsUtils.validateEmail,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'your.email@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Password field
              PasswordField(
                controller: _passwordController,
                label: 'Password',
                hintText: 'Enter your password',
                validator: (value) =>
                    ValidatorsUtils.validateRequired(value, 'Password'),
              ),
              const SizedBox(height: 12),

              // Remember me & Forgot password row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: CheckboxListTile(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      title: const Text('Remember me'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onForgotPassword,
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sign in button
              ElevatedButton(
                onPressed: widget.isLoading ? null : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24),

              // Sign up link
              Center(
                child: GestureDetector(
                  onTap: widget.onSignUp,
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
