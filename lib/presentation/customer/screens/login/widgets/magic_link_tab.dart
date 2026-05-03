import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/utils/validators_utils.dart';
import 'package:mobile_ai_erp/presentation/customer/store/signin_store.dart';
import 'package:mobile_ai_erp/presentation/customer/screens/register/widgets/email_verification_dialog.dart';
import '../../../widgets/auth_error_dialog.dart';

/// Magic code passwordless authentication tab widget
class MagicLinkTab extends StatefulWidget {
  final SignInStore signInStore;

  const MagicLinkTab({
    super.key,
    required this.signInStore,
  }) : super();

  @override
  State<MagicLinkTab> createState() => _MagicLinkTabState();
}

class _MagicLinkTabState extends State<MagicLinkTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MagicLinkTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.signInStore.errorMessage != null && widget.signInStore.errorMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AuthErrorDialog.show(
            context,
            message: widget.signInStore.errorMessage!,
            title: 'Magic Code Error',
          );
        }
      });
    }
  }

  void _handleRequestMagicLink() async {
    if (_formKey.currentState!.validate()) {
      final result = await widget.signInStore.requestMagicLink(email: _emailController.text.trim());
      if (result) {
        _emailController.text = widget.signInStore.magicLinkEmail ?? '';
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => EmailVerificationDialog(
              email: widget.signInStore.magicLinkEmail,
              signInStore: widget.signInStore,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildRequestView(context),
      ),
    );
  }

  Widget _buildRequestView(BuildContext context) {
    final isLoading = widget.signInStore.isMagicLinkLoading || widget.signInStore.isMagicLinkSent;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Passwordless Sign In',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'We\'ll send a secure code to your email',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Welcome message
          Text(
            'Sign in with a magic code',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No password needed. Enter your email to receive a secure sign-in code.',
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
            enabled: !isLoading,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'your.email@example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 24),

          // Send magic code button
          ElevatedButton(
            onPressed: isLoading ? null : _handleRequestMagicLink,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Text(
              'Send Magic Code',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared auth snackbar helper
class AuthSnackbar {
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: duration,
      ),
    );
  }
}
