import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_image.dart';

bool canRemoveCurrentBrandImage({
  required BrandImage? currentBrandImage,
  required String logoUrl,
  required bool hasPendingLogoFile,
  required bool removeImageOnSave,
}) {
  if (hasPendingLogoFile) {
    return true;
  }

  if (removeImageOnSave) {
    return false;
  }

  return currentBrandImage != null || logoUrl.trim().isNotEmpty;
}

bool shouldDeleteBrandImageOnSave({
  required Brand? editingBrand,
  required bool removeImageOnSave,
  required bool hasPendingLogoFile,
}) {
  return editingBrand != null && removeImageOnSave && !hasPendingLogoFile;
}

String? resolveBrandLogoUrlForSave({
  required Brand? editingBrand,
  required BrandImage? currentBrandImage,
  required String logoUrl,
  required bool removeImageOnSave,
  required bool hasPendingLogoFile,
}) {
  if (shouldDeleteBrandImageOnSave(
    editingBrand: editingBrand,
    removeImageOnSave: removeImageOnSave,
    hasPendingLogoFile: hasPendingLogoFile,
  )) {
    return currentBrandImage?.url ?? editingBrand?.logoUrl;
  }

  final trimmed = logoUrl.trim();
  return trimmed.isEmpty ? null : trimmed;
}
