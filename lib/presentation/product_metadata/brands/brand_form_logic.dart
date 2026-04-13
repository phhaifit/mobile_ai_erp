import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_image.dart';

bool shouldDeleteBrandImageOnSave({
  required Brand? editingBrand,
  required BrandImage? currentBrandImage,
  required String logoUrl,
  required bool hasPendingLogoFile,
}) {
  return editingBrand != null &&
      (currentBrandImage != null || (editingBrand.logoUrl?.isNotEmpty ?? false)) &&
      logoUrl.trim().isEmpty &&
      !hasPendingLogoFile;
}
