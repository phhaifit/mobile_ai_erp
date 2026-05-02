import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobile_ai_erp/presentation/customer/store/signup_store.dart';
import 'package:mobile_ai_erp/presentation/customer/store/signin_store.dart';

/// EmailVerificationDialog - Dialog for email verification flow
/// Displays verification code input and resend options
/// Supports both sign-up (verifyEmail) and sign-in (confirmMagicLink) flows
class EmailVerificationDialog extends StatefulWidget {
  final String? email;
  final SignUpStore? signUpStore;
  final SignInStore? signInStore;

  const EmailVerificationDialog({
    super.key,
    this.email,
    this.signUpStore,
    this.signInStore,
  }) : super();

  @override
  State<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isResending = false;
  int _resendCountdown = 0;

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Handle verification code input
  void _handleCodeInput(String value, int index) {
    if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    } else if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    }
  }

  /// Get the full verification code
  String _getFullCode() {
    return _codeControllers.map((c) => c.text).join();
  }

  /// Handle verification submission
  Future<void> _handleVerifyEmail() async {
    final code = _getFullCode();

    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete verification code'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Determine which store to use
    bool success = false;
    String? errorMsg;

    if (widget.signUpStore != null) {
      success = await widget.signUpStore!.verifyEmail(token: code);
      errorMsg = widget.signUpStore?.errorMessage;
    } else if (widget.signInStore != null) {
      success = await widget.signInStore!.confirmMagicLink(token: code);
      errorMsg = widget.signInStore?.errorMessage;
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store not available'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Close dialog after delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg ?? 'Verification failed',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle resend verification code
  Future<void> _handleResendCode() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      // Simulate API call to resend
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Start countdown
      setState(() {
        _resendCountdown = 60;
      });

      for (int i = 60; i > 0; i--) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _resendCountdown = i - 1;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resend failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Verify Your Email'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Description
              Text(
                'We sent a verification code to your email address. Enter it below to confirm.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              if (widget.email != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.email!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
              const SizedBox(height: 24),

              // Verification Code Input (6 digits)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => _buildCodeInput(index),
                ),
              ),
              const SizedBox(height: 24),

              // Verify Button
              ElevatedButton(
                onPressed: (widget.signUpStore?.isLoading ?? widget.signInStore?.isMagicLinkLoading ?? false)
                    ? null
                    : _handleVerifyEmail,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: (widget.signUpStore?.isLoading ?? widget.signInStore?.isMagicLinkLoading ?? false)
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Verify Email'),
              ),
              const SizedBox(height: 16),

              // Resend Code Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  GestureDetector(
                    onTap: _isResending || _resendCountdown > 0
                        ? null
                        : _handleResendCode,
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend in ${_resendCountdown}s'
                          : 'Resend',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _isResending || _resendCountdown > 0
                                ? Colors.grey
                                : Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Build individual code input field
  Widget _buildCodeInput(int index) {
    final isLoading = widget.signUpStore?.isLoading ?? widget.signInStore?.isMagicLinkLoading ?? false;
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: _codeControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        enabled: !isLoading,
        inputFormatters: [
          // Only digits
        ],
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => _handleCodeInput(value, index),
      ),
    );
  }
}

