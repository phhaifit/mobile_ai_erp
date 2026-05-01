/// Utility class for formatting error messages in the product metadata module.
class MetadataErrorFormatter {
  /// Formats a raw error object into a user-friendly message for UI actions.
  /// 
  /// It handles empty messages, generic "Instance of" strings, and removes
  /// common prefixes like "Exception: " or "Error: ".
  static String formatActionError({
    required Object error,
    required String actionLabel,
  }) {
    final message = error.toString().trim();
    final isGeneric =
        message.isEmpty ||
        message.toLowerCase().contains('instance of') ||
        message == 'Exception' ||
        message == 'Error';

    if (isGeneric) {
      return 'Couldn\'t $actionLabel. Try again.';
    }

    // Remove "Exception: " or "Error: " prefix if present for a cleaner UI
    return message.replaceFirst(RegExp(r'^(Exception|Error): '), '').trim();
  }
}
