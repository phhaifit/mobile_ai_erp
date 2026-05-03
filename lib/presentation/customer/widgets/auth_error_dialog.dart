import 'package:flutter/material.dart';

/// Reusable error dialog widget for authentication errors
class AuthErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isDismissible;

  const AuthErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.actionLabel,
    this.onAction,
    this.isDismissible = true,
  }) : super();

  static Future<void> show(
    BuildContext context, {
    required String message,
    String title = 'Error',
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AuthErrorDialog(
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.error_outline,
        color: Colors.red.shade600,
        size: 32,
      ),
      title: Text(title),
      content: SingleChildScrollView(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      actions: [
        if (actionLabel != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onAction?.call();
            },
            child: Text(actionLabel!),
          )
        else
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
      ],
    );
  }
}

/// Snackbar helper for showing auth messages
