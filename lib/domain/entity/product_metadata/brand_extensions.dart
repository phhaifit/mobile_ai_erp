import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';

extension BrandDescriptionX on Brand {
  bool get hasDescription => description?.trim().isNotEmpty == true;

  String? get descriptionOrNull {
    final trimmed = description?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
