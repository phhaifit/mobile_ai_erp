import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/metadata_page.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';

abstract class ProductMetadataRepository {
  Future<List<Category>> getCategories();
  Future<List<Category>> getCategoryTree();
  Future<Category> getCategoryById(String categoryId);
  Future<Category> saveCategory(Category category);
  Future<void> deleteCategory(String categoryId);

  Future<List<AttributeSet>> getAttributeSets();
  Future<AttributeSet> getAttributeSetById(String attributeSetId);
  Future<AttributeSet> saveAttributeSet(AttributeSet attributeSet);
  Future<void> deleteAttributeSet(String attributeSetId);

  Future<List<AttributeValue>> getAttributeValues(String attributeSetId);
  Future<List<AttributeValue>> getAllAttributeValues();
  Future<Map<String, int>> getAttributeValueCounts(List<String> attributeSetIds);
  Future<AttributeValue> saveAttributeValue(AttributeValue attributeValue);
  /// Deletes the attribute option identified by [optionId] from the
  /// attribute set identified by [attributeSetId].
  Future<void> deleteAttributeOption(String attributeSetId, String optionId);

  Future<MetadataPage<Brand>> getBrands({
    int page = 1,
    int pageSize = 20,
    String? search,
    bool includeInactive = false,
  });
  Future<Brand> getBrandById(String brandId);
  Future<Brand> saveBrand(Brand brand);
  Future<void> deleteBrand(String brandId);

  Future<List<Tag>> getTags();
  Future<Tag> getTagById(String tagId);
  Future<Tag> saveTag(Tag tag);
  Future<void> deleteTag(String tagId);

  Future<List<Unit>> getUnits({bool includeInactive = false});
  Future<Unit> getUnitById(String unitId);
  Future<Unit> saveUnit(Unit unit);
  Future<void> deleteUnit(String unitId);
}
