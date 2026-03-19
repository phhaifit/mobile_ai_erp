import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/attribute_option.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/brand.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/category_attribute.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/tag.dart';
import 'package:mobile_ai_erp/domain/entity/product_metadata/unit.dart';

abstract class ProductMetadataRepository {
  Future<List<Category>> getCategories();
  Future<Category> saveCategory(Category category);
  Future<void> deleteCategory(String categoryId);

  Future<List<Attribute>> getAttributes();
  Future<Attribute> saveAttribute(Attribute attribute);
  Future<void> deleteAttribute(String attributeId);

  Future<List<AttributeOption>> getAttributeOptions(String attributeId);
  Future<Map<String, int>> getAttributeOptionCounts(List<String> attributeIds);
  Future<AttributeOption> saveAttributeOption(AttributeOption attributeOption);
  Future<void> deleteAttributeOption(String attributeOptionId);

  Future<List<CategoryAttribute>> getCategoryAttributes();
  Future<CategoryAttribute> saveCategoryAttribute(CategoryAttribute item);
  Future<void> deleteCategoryAttribute(String categoryAttributeId);

  Future<List<Unit>> getUnits();
  Future<Unit> saveUnit(Unit unit);
  Future<void> deleteUnit(String unitId);

  Future<List<Brand>> getBrands();
  Future<Brand> saveBrand(Brand brand);
  Future<void> deleteBrand(String brandId);

  Future<List<Tag>> getTags();
  Future<Tag> saveTag(Tag tag);
  Future<void> deleteTag(String tagId);
}
