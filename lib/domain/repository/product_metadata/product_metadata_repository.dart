import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand_image.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';

abstract class ProductMetadataRepository {
  Future<MetadataPage<Category>> getCategories({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
    CategoryStatus? status,
    String? parentId,
    bool rootOnly = false,
  });
  Future<Category> getCategoryById(String categoryId);
  Future<Category> saveCategory(Category category);
  Future<void> deleteCategory(String categoryId);

  Future<MetadataPage<AttributeSet>> getAttributeSets({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  });
  Future<AttributeSet> getAttributeSetById(String attributeSetId);
  Future<AttributeSet> saveAttributeSet(AttributeSet attributeSet);
  Future<void> deleteAttributeSet(String attributeSetId);

  Future<List<AttributeValue>> getAttributeValues(String attributeSetId);
  Future<List<AttributeValue>> getAllAttributeValues();
  Future<AttributeValue> saveAttributeValue(AttributeValue attributeValue);

  /// Deletes the attribute value identified by [valueId] from the
  /// attribute set identified by [attributeSetId].
  Future<void> deleteAttributeValue(String attributeSetId, String valueId);

  Future<MetadataPage<Brand>> getBrands({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  });
  Future<Brand> getBrandById(String brandId);
  Future<Brand> saveBrand(Brand brand);
  Future<void> deleteBrand(String brandId);
  Future<BrandImage?> getBrandImage(String brandId);
  Future<BrandImage> uploadBrandImage(String brandId, dynamic file);
  Future<void> deleteBrandImage(String brandId);

  Future<MetadataPage<Tag>> getTags({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  });
  Future<Tag> getTagById(String tagId);
  Future<Tag> saveTag(Tag tag);
  Future<void> deleteTag(String tagId);
}
