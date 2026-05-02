import 'package:flutter/material.dart';
import 'package:mobile_ai_erp/utils/validators_utils.dart';
import '../../../widgets/auth_error_dialog.dart';

/// Magic link passwordless authentication tab widget
class MagicLinkTab extends StatefulWidget {
  final Function(String)? onSubmit;
  final bool isLoading;
  final String? errorMessage;
  final bool isLinkSent;

  const MagicLinkTab({
    Key? key,
    this.onSubmit,
    this.isLoading = false,
    this.errorMessage,
    this.isLinkSent = false,
  }) : super(key: key);

  @override
  State<MagicLinkTab> createState() => _MagicLinkTabState();
}

class _MagicLinkTabState extends State<MagicLinkTab> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  late bool _isLinkSent;

  @override
  void initState() {
    super.initState();
    _isLinkSent = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MagicLinkTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AuthErrorDialog.show(
            context,
            message: widget.errorMessage!,
            title: 'Magic Link Error',
          );
        }
      });
    }
    if (widget.isLinkSent && !_isLinkSent) {
      setState(() => _isLinkSent = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AuthSnackbar.showSuccess(
            context,
            message: 'Magic link sent! Check your email.',
            duration: const Duration(seconds: 4),
          );
        }
      });
    }
  }

  void _handleRequestMagicLink() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit?.call(_emailController.text.trim());
      setState(() => _isLinkSent = true);
    }
  }

  void _resetForm() {
    _emailController.clear();
    setState(() => _isLinkSent = false);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: widget.isLoading,
      message: 'Sending magic link...',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _isLinkSent ? _buildLinkSentView(context) : _buildRequestView(context),
      ),
    );
  }

  Widget _buildRequestView(BuildContext context) {
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
                        'We\'ll send a secure link to your email',
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
            'Sign in with a magic link',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No password needed. Enter your email to receive a secure sign-in link.',
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
            enabled: !widget.isLoading,
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

          // Send magic link button
          ElevatedButton(
            onPressed: widget.isLoading ? null : _handleRequestMagicLink,
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
              'Send Magic Link',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),

          // Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border: Border.all(color: Colors.amber.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'The link will expire in 24 hours for security.',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 13,
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

  Widget _buildLinkSentView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success state
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Check Your Email',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We\'ve sent a magic link to:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _emailController.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Click the link in the email to sign in. The link will expire in 24 hours.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Actions
        OutlinedButton(
          onPressed: _resetForm,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Try Different Email'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            // Trigger resend logic - would be handled by parent
          },
          child: const Text('Resend Link'),
        ),

        const SizedBox(height: 24),

        // Help section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Didn\'t receive the email?',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Check your spam or junk folder\n'
                '• Wait a few moments and refresh\n'
                '• Try signing up for a new account',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
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
