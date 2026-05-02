import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/di/service_locator.dart';
import 'package:mobile_ai_erp/presentation/customer/store/signup_store.dart';
import 'password_field.dart';
import 'email_verification_dialog.dart';

/// SignUpForm - Main sign-up form widget
/// Handles email, password input and form validation
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key}) : super();

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password strength
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validate confirm password matches
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate terms acceptance
  String? _validateTerms() {
    if (!_agreeToTerms) {
      return 'You must agree to the Terms and Conditions';
    }
    return null;
  }

  /// Handle form submission
  Future<void> _handleSignUp(SignUpStore signUpStore) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_validateTerms() != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms and Conditions'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Call the sign up action from store
    final success = await signUpStore.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success && signUpStore.isEmailVerificationPending) {
      // Show email verification dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => EmailVerificationDialog(
          email: signUpStore.verificationEmail ?? _emailController.text,
          signUpStore: signUpStore,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final signUpStore = getIt<SignUpStore>();

    return Form(
      key: _formKey,
      child: Observer(
        builder: (_) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              enabled: !signUpStore.isLoading,
              maxLength: 255,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'John',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailController,
              enabled: !signUpStore.isLoading,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'john@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 16),

            // Password Field
            PasswordField(
              controller: _passwordController,
              labelText: 'Password',
              enabled: !signUpStore.isLoading,
              validator: _validatePassword,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            _buildPasswordStrengthHint(),
            const SizedBox(height: 16),

            // Confirm Password Field
            PasswordField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              enabled: !signUpStore.isLoading,
              validator: _validateConfirmPassword,
            ),
            const SizedBox(height: 16),

            // Terms and Conditions Checkbox
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreeToTerms,
                    onChanged: signUpStore.isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: signUpStore.isLoading
                        ? null
                        : () {
                            setState(() {
                              _agreeToTerms = !_agreeToTerms;
                            });
                          },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'I agree to the ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: 'Terms and Conditions',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextSpan(
                            text: ' and ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
            const SizedBox(height: 24),

            // Sign Up Button
            ElevatedButton(
              onPressed: signUpStore.isLoading ? null : () => _handleSignUp(signUpStore),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: signUpStore.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            // Error Message Display
            if (signUpStore.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Text(
                    signUpStore.errorMessage ?? 'An error occurred',
                    style: TextStyle(color: Colors.red[900]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build password strength hint
  Widget _buildPasswordStrengthHint() {
    final password = _passwordController.text;
    late final Color hintColor;
    late final String hintText;

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    switch (strength) {
      case 1:
        hintColor = Colors.red;
        hintText = 'Weak password';
        break;
      case 2:
        hintColor = Colors.orange;
        hintText = 'Fair password';
        break;
      case 3:
        hintColor = Colors.amber;
        hintText = 'Good password';
        break;
      case 4:
        hintColor = Colors.green;
        hintText = 'Strong password';
        break;
      default:
        hintColor = Colors.grey;
        hintText = 'Very weak';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 4,
            decoration: BoxDecoration(
              color: hintColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            hintText,
            style: TextStyle(
              fontSize: 12,
              color: hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

