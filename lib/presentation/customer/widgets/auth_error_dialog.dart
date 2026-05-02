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

/// Widget for displaying a loading overlay with message
class LoadingOverlay extends StatelessWidget {
  final String message;
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    Key? key,
    required this.child,
    this.message = 'Loading...',
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Snackbar helper for showing auth messages
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

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: duration,
      ),
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        duration: duration,
      ),
    );
  }
}
