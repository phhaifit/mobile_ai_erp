import 'package:flutter/material.dart';

/// Google OAuth Sign-in button widget
class GoogleOAuthButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String label;
  final ButtonStyle? style;

  const GoogleOAuthButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Sign in with Google',
    this.style,
  }) : super();

  @override
  State<GoogleOAuthButton> createState() => _GoogleOAuthButtonState();
}

class _GoogleOAuthButtonState extends State<GoogleOAuthButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: widget.style ??
          ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey.shade800,
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      child: SizedBox(
        height: 48,
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey.shade600,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/google_icon.png',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Apple OAuth Sign-in button widget (future enhancement)
class AppleOAuthButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String label;
  final ButtonStyle? style;

  const AppleOAuthButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Sign in with Apple',
    this.style,
  }) : super(key: key);

  @override
  State<AppleOAuthButton> createState() => _AppleOAuthButtonState();
}

class _AppleOAuthButtonState extends State<AppleOAuthButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: widget.style ??
          ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
      child: SizedBox(
        height: 48,
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.apple, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
