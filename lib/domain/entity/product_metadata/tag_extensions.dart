import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';

extension TagExtensions on Tag {
  String? get descriptionOrNull {
    if (description == null) return null;
    final trimmed = description!.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
