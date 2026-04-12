import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/product_metadata_validation_exception.dart';

String? extractMetadataErrorMessage(Object? data) {
  if (data is Map<String, dynamic>) {
    final directMessage = data['message']?.toString();
    if (directMessage != null && directMessage.isNotEmpty) {
      return directMessage;
    }

    final error = data['error'];
    if (error is Map<String, dynamic>) {
      final nestedMessage = error['message']?.toString();
      if (nestedMessage != null && nestedMessage.isNotEmpty) {
        return nestedMessage;
      }
    }
  }

  final fallback = data?.toString();
  return fallback == null || fallback.isEmpty ? null : fallback;
}

Exception mapMetadataWriteError(DioException error) {
  final message = extractMetadataErrorMessage(error.response?.data);
  if (message == null || message.isEmpty) {
    return error;
  }
  return ProductMetadataValidationException(message);
}

/// Replaces disallowed ASCII control characters in metadata text before it is
/// encoded or sent over the network.
///
/// This sanitization helps prevent malformed JSON payloads, inconsistent server
/// parsing, and data integrity issues caused by non-printable characters being
/// embedded in metadata values.
///
/// **Characters replaced**: Control character ranges `0x00-0x08`, `0x0B`, `0x0C`, and `0x0E-0x1F`
/// (replaced with spaces, then trimmed).
///
/// **Characters preserved**:
/// - `\x09` (TAB) — Allowed for intentional formatting/indentation in multi-line text
/// - `\x0A` (LINE FEED/LF) — Allowed for intentional newlines in multi-line fields
/// - `\x0D` (CARRIAGE RETURN/CR) — Allowed as part of CRLF line endings (Windows format)
String sanitizeMetadataJsonText(String value) {
  return value.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), ' ').trim();
}

String? sanitizeNullableMetadataJsonText(String? value) {
  if (value == null) {
    return null;
  }

  final sanitized = sanitizeMetadataJsonText(value);
  return sanitized.isEmpty ? null : sanitized;
}

String encodeMetadataJsonBody(Map<String, dynamic> payload) {
  return jsonEncode(payload);
}
